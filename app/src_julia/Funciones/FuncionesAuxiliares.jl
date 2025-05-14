#import Pkg; Pkg.add("LinearRegression")
using LinearRegression
using Printf

#################################################################
# Funcoes de Ajuste
#################################################################

# sustraigo un background constante a la curva experimental
"""
    Funcion MejorBackGround

    parametros de entrada

    ajuste: vector con los datos a ajustar

    Dados_Exp: vector con los datos experimentales

    background0: valor inicial del background

    parametros de salida

    res.minimizer: valor del background que minimiza el error cuadratico

    The selected code is a Julia function called MejorBackGround that takes three arguments: ajuste, Dados_Exp, and background0.

        The purpose of this function is to find the best background value for a given set of experimental data. It does this by minimizing the sum of squared errors between the experimental data and a predicted value that is calculated as the sum of the background value and a value from the ajuste array.
        
        The function first defines an inner function called sqerror that takes a set of parameters (betas) and calculates the sum of squared errors as described above.
        
        Next, the function finds the minimum value in the Dados_Exp array and sets it to menordato. It then creates an instance of the LBFGS optimizer and uses it to minimize the sqerror function with the constraint that the background value must be between 0 and menordato. The initial guess for the background value is background0.
        
        Finally, the function returns the value of the background that minimizes the sum of squared errors.
"""
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
    #res = optimize(sqerror, [0., 0.],[300., 2.],[background0 , 1.],Fminbox(inner_optimizer))
    res = optimize(sqerror, [0. ],[menordato],[background0 ],Fminbox(inner_optimizer))
    #show(res)
    return res.minimizer
end;

# remuevo discontinuidades de la curva de calor especifico
# Deberia hacer un par de pasadas. Hago 2.
"""
    RemuevoSaltoEnC(Temps, CsT)
    Entrada:
        Temps: vector con las temperaturas
        CsT: vector con los valores de calor especifico
    Salida:
        c0: vector con los valores de calor especifico sin discontinuidades

    The selected code is a Julia function called RemuevoSaltoEnC that takes two arguments: Temps and CsT. The purpose of this function is to remove any sudden jumps or spikes in the CsT array that may occur due to measurement errors or other factors.

    The function first initializes an empty array called c0 of type Vector{Float64}. It then pushes the first element of the CsT array into c0.
            
    Next, the function loops through the CsT array from the second element to the second-to-last element. For each element, the function checks if the difference between the current element and its neighboring elements is greater than a certain threshold. If it is, then the function replaces the current element with the average of its neighboring elements. Otherwise, the function simply pushes the current element into c0.
            
    Finally, the function pushes the last element of the CsT array into c0 and returns c0.
            
    This function is useful for cleaning up noisy data and removing any sudden spikes or jumps that may be present. By replacing these spikes with the average of neighboring elements, the function can help to smooth out the data and make it easier to analyze.
            
    One possible way to improve the code would be to add more comments to explain the purpose of each line of code. Additionally, the function could be made more efficient by pre-allocating the c0 array instead of using push! to add elements one at a time.
"""
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


"""
    Calcula_CsT(CEF , trocas, Dados_ExpCp)
    Entrada:
        CEF: vector con los parametros de CEF
        trocas: vector con los parametros de acoplamientos
        Dados_ExpCp: vector con los datos experimentales de calor especifico
    Salida:
        CsTAux1: vector con los valores de calor especifico calculados
        The selected code is a Julia function called Calcula_CsT that takes three arguments: CEF, trocas, and Dados_ExpCp. The purpose of this function is to calculate the specific heat of a material as a function of temperature.

        The function first calls the SpinesEInteracoes function to calculate the interactions between the magnetic moments in the material. It then calls the BarroCampoTemp function to calculate the thermal properties of the material as a function of temperature. The resulting thermal properties are stored in the resultados variable.
            
        The function then extracts the temperature and entropy values from the resultados variable and calculates the specific heat using the formula ( Entrop[i] - Entrop[i+1] ) / ( Temps[i] - Temps[i+1] ). The resulting specific heat values are stored in the CsTAux3 array.
            
        The function then calls the RemuevoSaltoEnC function twice to remove any sudden jumps or spikes in the specific heat data. The resulting smoothed specific heat values are stored in the CsTAux1 array.
            
        Finally, the function returns the CsTAux1 array, which contains the specific heat values as a function of temperature.
            
        This function is useful for calculating the specific heat of a material as a function of temperature, which is an important property for understanding the behavior of the material. By removing any sudden jumps or spikes in the specific heat data, the function can help to smooth out the data and make it easier to analyze.
            
        One possible way to improve the code would be to add more comments to explain the purpose of each line of code. Additionally, the function could be made more efficient by pre-allocating the CsTAux3, CsTAux2, and CsTAux1 arrays instead of using push! to add elements one at a time.    
"""

kB = 8.617333262*10^-5 #* eV / K      https://en.wikipedia.org/wiki/Boltzmann_constant
muB = 5.7883818060 * 10^-5 #* eV / T  https://en.wikipedia.org/wiki/Bohr_magneton
const KB = 8314.46261815324 #mJ⋅K−1⋅mol−1
const muBemu=0.5586  # muB en emu
const muBKsT=0.671713816 #muB/kB

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

"""
    gerar_temperaturas(inicio, fim, n_pontos)
    Entrada:
        inicio: valor inicial de temperatura
        fim: valor final de temperatura
        n_pontos: numero de pontos
    Salida:
        numeros: vector con los valores de temperatura
    
    The selected code is a Julia function called gerar_temperaturas that takes three arguments: inicio, fim, and n_pontos. The purpose of this function is to generate a list of temperatures that are evenly spaced between the given start and end values.

    The function first calculates the step size by dividing the difference between the start and end values by the number of points minus one. It then creates a vector called numeros that contains the start value plus the step size times the index for each point.
            
    Finally, the function returns the numeros vector, which contains the evenly spaced temperatures.
            
    This function is useful for generating a list of temperatures that are evenly spaced between two given values. By using this function, you can easily create a list of temperatures that can be used in other calculations or functions.
            
    One possible way to improve the code would be to add more comments to explain the purpose of each line of code. Additionally, the function could be made more efficient by pre-allocating the numeros array instead of using push! to add elements one at a time.

"""
function gerar_temperaturas(inicio, fim, n_pontos)
    passo = (fim - inicio) / (n_pontos + 1)
    numeros = [round(inicio + i * passo, digits=2) for i = 0:n_pontos + 1]
    return  numeros
end

"""
    Ajst_CsT(CEF , trocas, Dados_ExpCp)
    Entrada:
        CEF: vector con los parametros de CEF
        trocas: vector con los parametros de acoplamientos
        Dados_ExpCp: vector con los datos experimentales de calor especifico
    Salida:
        Qualidade_Ajst: valor de la calidad del ajuste
        CsT: vector con los valores de calor especifico calculados

    The selected code is a Julia function called Ajst_CsT that takes three arguments: CEF, trocas, and Dados_ExpCp. The purpose of this function is to adjust the specific heat data for a material by subtracting a background value and returning the resulting adjusted specific heat data.

    The function first calls the Calcula_CsT function to calculate the specific heat of the material as a function of temperature. The resulting specific heat values are stored in the CsTAux1 array.
            
    The function then calls the MejorBackGround function to find the best background value for the specific heat data. The background value is calculated by minimizing the sum of squared errors between the experimental specific heat data and the predicted specific heat data, which is calculated as the sum of the specific heat data and a background value. The initial guess for the background value is 0.1. The resulting background value is stored in the background variable.
            
    The function then subtracts the background value from the specific heat data and stores the resulting adjusted specific heat data in the CsT array.
            
    Finally, the function calculates the quality of the adjustment by summing the squared differences between the adjusted specific heat data and the experimental specific heat data. The resulting quality value is stored in the Qualidade_Ajst variable.
            
    The function returns a tuple containing the quality of the adjustment and the adjusted specific heat data.
            
    This function is useful for adjusting specific heat data for a material by subtracting a background value. By finding the best background value that minimizes the sum of squared errors between the experimental specific heat data and the predicted specific heat data, the function can help to remove any systematic errors or noise in the data.
            
    One possible way to improve the code would be to add more comments to explain the purpose of each line of code. Additionally, the function could be made more efficient by pre-allocating the CsTAux1 and CsT arrays instead of using push! to add elements one at a time    
"""
function Ajst_CsT(CEF , trocas, Dados_ExpCp)
    CsTAux1 = Calcula_CsT(CEF , trocas, Dados_ExpCp)
    background = MejorBackGround(CsTAux1, Dados_ExpCp.dados.Cp, 0.1)
    CsT = CsTAux1 .+ background[1]
    #CsT = [ ( Entrop[i] - Entrop[i+1] ) / ( Temps[i] - Temps[i+1] ) for i = 1:size(Entrop)[1]-1 ]
    Qualidade_Ajst = sum((CsT[i] - Dados_ExpCp.dados.Cp[i])^2 for i in eachindex(CsT));
    return (Qualid_Ajst = Qualidade_Ajst, CsT = CsT )
end


function Calcula_Chi(CEF , trocas, Dados_Exp)
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp([Dados_Exp.Modulo_del_campo], Dados_Exp.Direc_Campo, Dados_Exp.dados.Temp, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    # el g efectivo es la media de los g de los sitios
    geff = sum(SpinesEnRed[i].gJ for i in eachindex(SpinesEnRed))/size(SpinesEnRed)[1] 
    ChiAux = resultados.PropTermo[:,3] .* ( geff * muBemu  / Dados_Exp.Modulo_del_campo );
    return ChiAux
end

"""
    Ajst_Chi(CEF, trocas, Dados_Exp)

    Calculates the susceptibility and quality of fit for a given set of experimental data.

    # Arguments
    - `CEF`: named tuple of crystal field constants.
    - `trocas`: named tuple of exchange coupling constants.
    - `Dados_Exp::DadosExp`: experimental data.

    # Returns
    - `Qualid_Ajst::Float64`: quality of fit.
    - `Suscept::Array{Float64,1}`: susceptibility values.
"""
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

function calcula_mag(CEF , trocas, Dados_ExpMag)
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp(Dados_ExpMag.dados.Field, Dados_ExpMag.Direc_Campo, Dados_ExpMag.Temp, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    geff = sum(SpinesEnRed[i].gJ for i in eachindex(SpinesEnRed))/size(SpinesEnRed)[1] 
    Mag = resultados.PropTermo[:,3] .* ( geff * muBemu ) * 10000;
    return Mag
end

# imprimo la configuracion a una dada temperatura y campo
function ConfiguracionMagnetica(CEF, trocas, Dados)
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp(Dados.dados.Field, Dados.Direc_Campo, Dados.Temp, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    return resultados
end

function calcula_spin(CEF , trocas, Temperatura=2., Campo=0.01, DirCampo=[ 0 0 1 ])
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp([Campo], DirCampo, [Temperatura], TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    SoloPosicionesAtomos = vcat(Posiciones[:,6]...)
return hcat(SoloPosicionesAtomos,resultados.UltConfSpin)
end

#funcion para imprimir parte real e imaginaria de un vector de complejos
function ImprimoSpin(archSal, vectorx)
    arch = open(archSal, "w")
    for i in axes(vectorx,1)
        @printf(arch, " %.4f  %.4f  %.4f  %.4f  %.4f  %.4f \n", vectorx[i,1], vectorx[i,2], vectorx[i,3], vectorx[i,4], vectorx[i,5], vectorx[i,6])
    end
    close(arch)
end


"""
    Ajst_Mag(CEF, trocas, Dados_ExpMag)

    This function calculates the magnetization and quality of fit for a given set of experimental data and parameters.

    # Arguments
    - `CEF`: crystal electric field parameters
    - `trocas`: exchange interactions
    - `Dados_ExpMag`: experimental data

    # Returns
    - `Qualid_Ajst`: quality of fit
    - `Magnetizacion`: magnetization
"""
function Ajst_Mag(CEF , trocas, Dados_ExpMag)
    Mag = calcula_mag(CEF , trocas, Dados_ExpMag)
    Qualidade_Ajst = sum((Mag[i] - Dados_ExpMag.dados.Mag[i])^2 for i in eachindex(Mag));
    return (Qualid_Ajst = Qualidade_Ajst, Magnetizacion = Mag )
end

"""
    encontrar_TN_maximo_cambio_entropia(CEF, trocas, Dados)

    Esta função recebe como entrada o CEF (a named tuple), as trocas (tambem a named tuple) e os Dados (basicamente um range de temperaturas), e retorna o valor de temperatura (TN) correspondente ao máximo de mudança de entropia (DeltaCsT) calculado a partir dos dados de entropia (CsT) obtidos a partir dos objetos de entrada.

    # Arguments
    - `CEF`: named tuple com o campo cristalino.
    - `trocas`: named tuple com as trocas.
    - `Dados::Any`: objeto Dados.

    # Returns
    - `TNDeltaCsT::Float64`: valor de temperatura (TN) correspondente ao máximo de mudança de entropia (DeltaCsT).

"""
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

#Calcular valor de Theta;
"""
    Calcular_Theta(CEF , trocas, Dados_Exp,Tmin=300, Tmax=100, NptosT=30 )

    Calculates the Curie-Weiss temperature and the inverse of the Curie constant 
    for a given crystal electric field (CEF), exchange interactions (trocas), 
    experimental data (Dados_Exp), minimum temperature (Tmin), maximum temperature (Tmax), and number of temperature points (NptosT).

    # Arguments
    - `CEF::Array{Float64,2}`: NamedTuple with the crystal electric field Hamiltonian.
    - `trocas::Array{Float64,2}`: NamedTuple with the exchange interactions.
    - `Dados_Exp::ExpData`: experimental data.
    - `Tmin::Float64=300`: minimum temperature.
    - `Tmax::Float64=100`: maximum temperature.
    - `NptosT::Int=30`: number of temperature points.

    # Returns
    - `Tuple{Float64, Float64}`: Curie-Weiss temperature and inverse of the Curie constant.

"""
function Calcular_Theta(CEF , trocas, Dados_Exp,Tmin=300, Tmax=100, NptosT=30 )
    #Defino Temperaturas;
    Temperaturas = [ Tmin + (Tmax - Tmin) / (NptosT - 1) * i for i = 0:NptosT-1 ] ;
    (SpinesEnRed,  SitioEInt ) = SpinesEInteracoes(CEF , trocas)
    resultados = BarroCampoTemp([Dados_Exp.Modulo_del_campo], Dados_Exp.Direc_Campo, Temperaturas, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesEnRed, HEfetivoSitio);
    geff = sum(SpinesEnRed[i].gJ for i in eachindex(SpinesEnRed))/size(SpinesEnRed)[1] 
    ChiAux = resultados.PropTermo[:,3] .* (  geff* muBemu  / Dados_Exp.Modulo_del_campo );
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

"""
    calcular_splitting_CEF_inicial(CEFA,trocas)

    Calculates the initial CEF splitting for a given crystal field Hamiltonian `CEFA` and a set of exchange interactions `trocas`. Interactions are taken as zero. The function returns the energies of the eigenstates and the eigenvectors of the Hamiltonian. The results are also printed to the screen.

    # Arguments
    - `CEFA::Array{Float64,2}`: The crystal field Hamiltonian.
    - `trocas::Dict{String,Float64}`: A dictionary with the exchange interactions.

    # Returns
    - `Energias::Array{Float64,1}`: The energies of the eigenstates.
    - `Vetores::Array{ComplexF64,2}`: The eigenvectors of the Hamiltonian.

"""
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

"""
    exportar_resultados(resultados)

    Exporta os resultados das energias e autofuncoes para um arquivo de texto.

    # Arguments
    - `resultados::NamedTuple`: um NamedTuple contendo as energias e vetores de autoestados.

"""
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

using Printf

"""
    ImprimoXT(archSal, vectorx, vectory)

    funcion para imprimir parte real e imaginaria de un vector de complejos
"""
function ImprimoXT(archSal, vectorx, vectory, modo = "w")
    arch = open(archSal, modo)
    for i in eachindex(vectorx)
        @printf(arch, " %.4f  %.4f \n", vectorx[i], vectory[i] )
    end
    @printf(arch, "\n\n")  
    close(arch)
end

using Optim
struct MySimplexer <: Optim.Simplexer end
#Optim.simplexer(S::MySimplexer, initial_x) = [rand(length(initial_x)) for i = 1:length(initial_x)+1]
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
"""
    DictToNamedTupla(Diccionario)

    Converts a dictionary to a named tuple.

    # Arguments
    - `Diccionario::Dict`: A dictionary to be converted to a named tuple.

    # Returns
    - `Tupla::NamedTuple`: A named tuple with the elements of the dictionary.

"""
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


using JSON
# definir la funcion que lee el archivo JSON y devuelve las tuplas por separado
"""
LeoParametros - Reads a JSON file and converts it into named tuples.

    # Arguments
    - `nombrearch::String`: The path to the JSON file.

    # Returns
    - `nothing`
    - Four (global) NamedTuples containing the parameters to be adjusted and the parameters to be kept constant. The first two contain the crystal field parameters, while the last two contain the exchange interactions. Their names are `ParametrosCEFAAjustarTupla`, `ParametrosCEFANoAjustarTupla`, `ParametrosJsAAjustarTupla`, and `ParametrosJsANoAjustarTupla`.

"""
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
"""
    CEFeJsToXs(CEF, Js)
        Converts two NamedTuples, CEF and Js, into a single array x by concatenating them.

        # Arguments
        - `CEF::Array{Float64}`: A NamedTuples with the crystal field parameters.
        - `Js::Array{Float64}`: A NamedTuples with the exchange interactions.

        # Returns
        - `x::Array{Float64}`: An array of Float64 values obtained by concatenating CEF and Js.
"""
function CEFeJsToXs(CEF, Js)
    x = Array{Float64}(undef, 0)
    for value in CEF
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
"""
    XsToCEFeJs(x)

    Converts an array `x` to two named tuples `CEF` and `Js` containing the parameters to be adjusted for a model.

    # Arguments
    - `x::Array`: an array with the parameters to be adjusted.

    # Returns
    - `CEF::NamedTuple`: a named tuple containing the parameters to be adjusted for the CEF model.
    - `Js::NamedTuple`: a named tuple containing the parameters to be adjusted for the Js model.
"""
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

