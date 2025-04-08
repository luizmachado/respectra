
#################################################################
# Funcoes de Ajuste
#################################################################

# sustraigo un background constante a la curva experimental
function MejorBackGround(ajuste, Dados_Exp, background0)
    function sqerror(betas)
        err = 0.0
        for i in eachindex(ajuste)
            pred_i = betas[1] + ajuste[i] # betas[2] *
            err += (Dados_Exp[i] - pred_i)^2
        end
        return err
    end
    
    menordato = minimum(Dados_Exp)
    #println(menordato)
    #impongo que el background este entre 0 y el menor valor medido LBFGS()
    inner_optimizer = LBFGS()
#    res = optimize(sqerror, [0., 0.],[300., 2.],[background0 , 1.],Fminbox(inner_optimizer))
    res = optimize(sqerror, [0. ],[menordato],[background0 ],Fminbox(inner_optimizer))
    #show(res)
    return res.minimizer
end;

# remuevo discontinuidades de la curva de calor especifico
# Deberia hacer un par de pasadas. Hago 2.
function RemuevoSaltoEnC(Temps, CsT)
    c0 = Vector{Float64}()
    push!(c0 , CsT[1] )
    for i in 2:size(Temps)[1] - 1
        if (CsT[i] - CsT[i-1]) > CsT[i] * abs(Temps[i] - Temps[i-1]) / Temps[i] && 
                 (CsT[i] - CsT[i+1]) > CsT[i] * abs(Temps[i] - Temps[i+1]) / Temps[i]
            medio = (CsT[i-1] + CsT[i+1]) / 2.
            push!(c0 ,  medio )
            #println("Ajusto en ", Temps[i],"  ", CsT[i],"  ",medio )
        else
            push!(c0 , CsT[i] )
        end
    end
    push!(c0 , CsT[size(Temps)[1]] )
    return c0
end;

function Calcula_Entrop(CEF , trocas, Dados_ExpCp)
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp([Dados_ExpCp.Modulo_del_campo], Dados_ExpCp.Direc_Campo, Dados_ExpCp.dados.Temp, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    Temps = resultados.PropTermo[:,1]
    Entrop = KB .* resultados.PropTermo[:,4]
    #ImprimoXT("Entropia.txt", Temps, Entrop)
    return Entrop
end

function Calcula_CsT(CEF , trocas, Dados_ExpCp)
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp([Dados_ExpCp.Modulo_del_campo], Dados_ExpCp.Direc_Campo, Dados_ExpCp.dados.Temp, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    Temps = resultados.PropTermo[:,1]
    Entrop = KB .* resultados.PropTermo[:,4]
    #ImprimoXT("Entropia.txt", Temps, Entrop)
    CsTAux3 = [ ( Entrop[i] - Entrop[i+1] ) / ( Temps[i] - Temps[i+1] ) for i = 1:size(Entrop)[1]-1 ]
    CsTAux2 = RemuevoSaltoEnC(Temps[1:size(Temps)[1] - 1,1], CsTAux3)
    CsTAux1 = RemuevoSaltoEnC(Temps[1:size(Temps)[1] - 1,1], CsTAux2)
    return CsTAux1
end

function gerar_temperaturas(inicio, fim, n_pontos)
    passo = (fim - inicio) / (n_pontos + 1)
    numeros = [round(inicio + i * passo, digits=2) for i = 0:n_pontos + 1]
    return  numeros
end

function Ajst_CsT(CEF , trocas, Dados_ExpCp)
    CsTAux1 = Calcula_CsT(CEF , trocas, Dados_ExpCp)
    background = MejorBackGround(CsTAux1, Dados_ExpCp.dados.Cp, 0.1)
    CsT = CsTAux1 .+ background[1]
#    CsT = [ ( Entrop[i] - Entrop[i+1] ) / ( Temps[i] - Temps[i+1] ) for i = 1:size(Entrop)[1]-1 ]
    Qualidade_Ajst = sum((CsT[i] - Dados_ExpCp.dados.Cp[i])^2 for i in eachindex(CsT));
    return (Qualid_Ajst = Qualidade_Ajst, CsT = CsT )
end


function Calcula_Chi(CEF , trocas, Dados_Exp)
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp([Dados_Exp.Modulo_del_campo], Dados_Exp.Direc_Campo, Dados_Exp.dados.Temp, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    ChiAux = resultados.PropTermo[:,3] .* ( gJTb * muBemu  / Dados_Exp.Modulo_del_campo );
    return ChiAux
end

function Ajst_Chi(CEF , trocas, Dados_Exp)
    ChiAux = Calcula_Chi(CEF , trocas, Dados_Exp)
    background = MejorBackGround(ChiAux, Dados_Exp.dados.Chi, 0.00001)
    Chi = ChiAux .+ background[1]
    Qualidade_Ajst = sum((Chi[i] - Dados_Exp.dados.Chi[i])^2 for i in eachindex(Chi));
    return (Qualid_Ajst = Qualidade_Ajst, Suscept = Chi )
end

function gerar_campos(inicio, fim, n_pontos)
    passo = (fim - inicio) / (n_pontos + 1)
    numeros = [round(inicio + i * passo, digits=2) for i = 0:n_pontos + 1]
    return  numeros
end

function Calcula_Mag(CEF , trocas, Dados_ExpMag)
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp(Dados_ExpMag.dados.Field, Dados_ExpMag.Direc_Campo, Dados_ExpMag.Temp, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    Mag = resultados.PropTermo[:,3] .* ( gJTb * muBemu ) * 10000;
    return Mag
end

function Ajst_Mag(CEF , trocas, Dados_ExpMag)
    MagAux = Calcula_Mag(CEF, trocas, Dados_ExpMag)
    Qualidade_Ajst = sum((MagAux[i] - Dados_ExpMag.dados.Mag[i])^2 for i in eachindex(MagAux));
    return (Qualid_Ajst = Qualidade_Ajst, Magnetizacion = MagAux )
end

function encontrar_TN_maximo_cambio_entropia(CEF , trocas, Dados)
    # Seleciona a coluna de entropia
    CsT = Calcula_CsT(CEF , trocas, Dados)
    # Calcula DeltaCsT
    DeltaCsT = [abs(CsT[i] - CsT[i+1]) for i = 1:size(CsT)[1]-1]
    # Encontra o índice do máximo de DeltaCsT
    idx_max = argmax(DeltaCsT)
    # Encontra o valor de TN correspondente ao máximo
    TNDeltaCsT = Dados.dados.Temp[idx_max]
    
    return TNDeltaCsT
end

import Pkg; Pkg.add("LinearRegression")
using LinearRegression
#Calcular volor de Theta;
function Calcular_Theta(CEF , trocas, Dados_Exp,Tmin=300, Tmax=100, NptosT=30 )
    #Defino Temperaturas;
    Temperaturas = [ Tmin + (Tmax - Tmin) / (NptosT - 1) * i for i = 0:NptosT-1 ] ;
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp([Dados_Exp.Modulo_del_campo], Dados_Exp.Direc_Campo, Temperaturas, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    ChiAux = resultados.PropTermo[:,3] .* ( gJTb * muBemu  / Dados_Exp.Modulo_del_campo );
    InvChiAux = 1 ./ ChiAux
    #a, b = linreg(Temps, ChiAux)          # Linear regression
    lr = linregress(Temperaturas, InvChiAux)
    #a*x + b
    Theta = LinearRegression.bias(lr)/LinearRegression.slope(lr)[1]
    #print("\n (B par c) Theta=", LinearRegression.bias(lr) ,"  1/ConstCurie=", LinearRegression.slope(lr)[1])
    return (Theta , 1/LinearRegression.slope(lr)[1])
    #println(Temperaturas,InvChiAux)
end

using Printf

function calcular_splitting_CEF_inicial(CEFA,trocas)
    # Garante a região paramagnética
    trocas0 = deepcopy(trocas)
    # cero todos los campos en trocas0
    for key in keys(trocas0)
        val = trocas0[key]
        #println("$key => $val")
        trocas0[key] => 0.
    end

    (SpinesEnRed, SitioEInt ) = SpinesEInteracoes(CEFA , trocas0)
    HCEF = HEfetivoSitio([ 0. 0. 0.], SpinesEnRed[SitioEInt[1].Tipo], SitioEInt[1].VEI, TablaValMedSpines,TablaValorMedioO20)
    #Calcula as energias dos Estados
    Energias = real(eigvals(HCEF))
    Autoestados = eigvecs(HCEF)
    SplitCEF = last(Energias) - Energias[1]
    # Imprime os resultados em uma tabela
    println("\n Índice | Energia | Autoestado") 
    println("==============================")
    for i in eachindex(Energias)
        idx_str = lpad(string(i), 2)
        energia_str = @sprintf("%.4f", Energias[i])
        autoestado_str = join(["$(lpad(@sprintf("%.4f", real(x)), 7)) + $(lpad(@sprintf("%.4f", imag(x)), 7))i" for x in Autoestados[i, :]], ", ")
        println("$idx_str | $energia_str | $autoestado_str")
    end
   # println("Splitting CEF inicial = $SplitCEF")
   # println(Energias .- Energias[1])
   # println(Autoestados)
    return (Energias = Energias,Vetores = Autoestados)
end

function exportar_resultados(resultados)
    # Abre o arquivo para escrita
    arquivo = open("resultados.txt", "w")
    
    for (i, Energias) in enumerate(resultados.Energias)
        println(arquivo, "Índice $i:")
        println(arquivo, "- Energia: $(Energias)")
        println(arquivo, "- Autoestado:")
        
        for autoestado in resultados.Vetores[i, :]
            println(arquivo, "  - Parte Real: $(real(autoestado)), Parte Imaginária: $(imag(autoestado))")
        end
        
        println(arquivo, "\n")
    end
    #println(resultados)
    # Fecha o arquivo
    close(arquivo)
end

function calcula_spin(CEF , trocas, Temperatura=2., Campo=0.01, DirCampo=[ 0 0 1 ])
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp([Campo], DirCampo, [Temperatura], TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    SoloPosicionesAtomos = vcat(Posiciones[:,6]...)
return hcat(SoloPosicionesAtomos,resultados.UltConfSpin)
end

using Printf

#funcion para imprimir parte real e imaginaria de un vector de complejos
function ImprimoXT(archSal, vectorx, vectory)
    arch = open(archSal, "w")
    for i in eachindex(vectorx)
        @printf(arch, " %.4f  %.4f \n", vectorx[i], vectory[i] )
    end
    close(arch)
end
#funcion para imprimir parte real e imaginaria de un vector de complejos
function ImprimoSpin(archSal, vectorx)
    arch = open(archSal, "w")
    for i in axes(vectorx,1)
        @printf(arch, " %.4f  %.4f  %.4f  %.4f  %.4f  %.4f \n", vectorx[i,1], vectorx[i,2], vectorx[i,3], vectorx[i,4], vectorx[i,5], vectorx[i,6])
    end
    close(arch)
end

import Pkg; Pkg.add("Optim")
using Optim
struct MySimplexer <: Optim.Simplexer end
Optim.simplexer(S::MySimplexer, initial_x) = [rand(length(initial_x)) for i = 1:length(initial_x)+1]
function Optim.simplexer(S::MySimplexer, initial_x::AbstractArray{T, N}) where {T, N}
    n = length(initial_x)
   # Creo vector de vectores con el punto iniciales
    initial_simplex = Array{T, N}[initial_x for i = 1:n+1]
   # A cada columna del initial_simplex le sumo un vector con un valor aleatorio
    for j = 1:n
          initial_simplex[j+1][j] += 0.001 .* (0.1 .+ rand() )
    end
    return initial_simplex
end



struct MatlabSimplexer{T} <: Optim.Simplexer
    a::T
    b::T
end
MatlabSimplexer(;a = 0.001, b = 0.05) = MatlabSimplexer(a, b)

function Optim.simplexer(A::MatlabSimplexer, initial_x::AbstractArray{T, N}) where {T, N}
    n = length(initial_x)
    #println("inicial:",initial_x)
    initial_simplex = Array{T, N}[deepcopy(initial_x) for i = 1:n+1]
    for j = 1:n
        #println("antes",j,initial_simplex[j+1])
        initial_simplex[j+1][j] += initial_simplex[j+1][j] == zero(T) ? A.a : A.b * initial_simplex[j+1][j]  
        #initial_simplex[j+1][j] +=  0.5 * initial_simplex[j+1][j] + 0.001 
        #println(initial_simplex[j+1])
    end
    #println(initial_simplex)
    #exit()
    return initial_simplex
end



#defino la funcion que paso de diccionario a named tuple
function DictToNamedTupla(Diccionario)
    Tupla=NamedTuple()
    for (key, value) in Diccionario
        #println("$key = $value")
        #agrego a tupla el elemento key=>value
        TuplaAux=merge(Tupla,[Meta.parse.(key)=>value])
        Tupla=deepcopy(TuplaAux)
    end
    return Tupla
end


import Pkg; Pkg.add("JSON")
using JSON
# definir la funcion que lee el archivo JSON y devuelve las tuplas por separado
function LeoParametros(nombrearch)
    # Abrir o arquivo e ler o conteúdo
    ArchPar = open(nombrearch, "r")
    texto = read(ArchPar, String)
    close(ArchPar)

    # Converter o texto JSON em um dicionário Julia
    parametros = JSON.parse(texto)
    #separo los parametros que ajusto y los que no de CEF
    ParametrosCEF=parametros["CEF"]
    ParametrosCEFAAjustar=ParametrosCEF["Ajustar"]
    ParametrosCEFANoAjustar=ParametrosCEF["NoAjustar"]
    #separo los Acoplamientos
    ParametrosJs=parametros["Acoplamientos"]
    ParametrosJsAAjustar=ParametrosJs["Ajustar"]
    ParametrosJsANoAjustar=ParametrosJs["NoAjustar"]

    # paso el diccionario ParametrosCEFAAjustar a named tuple
    global ParametrosCEFAAjustarTupla=DictToNamedTupla(ParametrosCEFAAjustar)
    # paso el diccionario ParametrosCEFANoAjustar a named tuple
    global ParametrosCEFANoAjustarTupla=DictToNamedTupla(ParametrosCEFANoAjustar)
    # paso el diccionario ParametrosJsAAjustar a named tuple
    global ParametrosJsAAjustarTupla=DictToNamedTupla(ParametrosJsAAjustar)
    # paso el diccionario ParametrosJsANoAjustar a named tuple
    global ParametrosJsANoAjustarTupla=DictToNamedTupla(ParametrosJsANoAjustar)
    return
end

#Paso valores de CEF y Acoplamientos a ajustar a un vector x
function CEFeJsToXs(CEF, Js)
    x = Array{Float64}(undef, 0)
    for value in CEF
        #println(value)
        xAux=vcat(x,[value])
        x=deepcopy(xAux)
    end
    for value in Js
        xAux=vcat(x,[value])
        x=deepcopy(xAux)
    end
    return x
end

#Conversion inversa. Paso x a CEF y Js. necesita ParametrosCEFAAjustarTupla y ParametrosJsAAjustarTupla como globales...
function XsToCEFeJs(x)
    CEF = NamedTuple()
    Js = NamedTuple()
    indice=1
    for key in keys(ParametrosCEFAAjustarTupla)
        #println("$key = $value")
        #agrego a tupla el elemento key=>value
        CEF=merge(CEF,[key=>x[indice]])
        indice+=1
    end
    for key in keys(ParametrosJsAAjustarTupla)
        #println("$key = $value")
        #agrego a tupla el elemento key=>value
        Js=merge(Js,[key=>x[indice]])
        indice+=1
    end
    return CEF, Js
end

