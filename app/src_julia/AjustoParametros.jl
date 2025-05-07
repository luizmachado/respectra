#################################################################
# NO CAMBIAR ESTA PARTE
#################################################################
include("CampoMedioBase.jl")
using .CampoMedio
include("FuncionesAuxiliares.jl")
using Pkg
# Pkg.add("Optim")

#################################################################
# Leo dados Experimentais
#################################################################
include("DatosExperimentais.jl")

#################################################################
# Rede, hamiltoniano y tipo de spin
#################################################################
include("Rede.jl")

#################################################################
# Busco parametros optimos 
#################################################################
include("LeoParametrosJSON.jl")

# ajuste por 1200s = 20min

# Variamos x en el rango -1 a 1 con 10 puntos 
#=
x = range(-.1, .1, length = 10)
# calculamos el valor de Ajst_Chi para estos valores de x
for x0 in x
    CEFAux = XsToCEFeTrocas([CEF0.B20 x0])
    CEFA = merge(CEFAux.CEF, (B43 = CEF0.B43, B60 = CEF0.B60, B63 = CEF0.B63, B66 = CEF0.B66, B4M3 = CEF0.B4M3, B6M3 = CEF0.B6M3, B6M6 = CEF0.B6M6))
    Rodada_Aux_MT1 = Ajst_Chi(CEFA , trocas0, Dados_Exp1MT )
    Rodada_Aux_MT2 = Ajst_Chi(CEFA , trocas0, Dados_Exp2MT )
    #calculamos fun_ajst con valores de entrada CEF0.B20 y x0
    FunCalidad = fun_ajst([CEF0.B20 x0])

    #imprime en pantalla el valor de x0 y el valor de Ajst_Chi
    println(x0,"\t", Rodada_Aux_MT1.Qualid_Ajst,"\t", Rodada_Aux_MT2.Qualid_Ajst,"\t",Dados_Exp2MT.Peso_Ajs,"\t", FunCalidad)
end
=#
# termino aca el codigo
#exit()

#################################################################
# Defino la funcion de ajuste (que ajusto)
#################################################################
function fun_ajst(x)
    CEFNuevo, JsNuevo  = XsToCEFeJs(x)
    CEFA = merge(CEFNuevo,ParametrosCEFANoAjustarTupla)
    trocas = merge(JsNuevo,ParametrosJsANoAjustarTupla)
    # a partir de aca agregar los ajustes que se quieran
    #Rodada_Aux_CsT = Ajst_CsT(CEFA , trocas, Dados_ExpCsT )
    Rodada_Aux_MT1 = Ajst_Chi(CEFA , trocas, Dados_Exp1MT )
    Rodada_Aux_MT2 = Ajst_Chi(CEFA , trocas, Dados_Exp2MT )
    #Rodada_Aux_MH1 = Ajst_Mag(CEFA , trocas, Dados_Exp1MH )
    #Rodada_Aux_MH2 = Ajst_Mag(CEFA , trocas, Dados_Exp2MH )
    return Rodada_Aux_MT1.Qualid_Ajst * Dados_Exp1MT.Peso_Ajs + 
           Rodada_Aux_MT2.Qualid_Ajst * Dados_Exp2MT.Peso_Ajs 
           #Rodada_Aux_CsT.Qualid_Ajst * Dados_ExpCsT.Peso_Ajs +
           #Rodada_Aux_MH1.Qualid_Ajst * Dados_Exp1MH.Peso_Ajs + 
           #Rodada_Aux_MH2.Qualid_Ajst * Dados_Exp2MH.Peso_Ajs 
end


# si los parametros a ajustar son mas de uno, hago la minimizacion
if (length(ParametrosCEFAAjustarTupla) + length(ParametrosJsAAjustarTupla) > 0 )
    #initial_simplex = MySimplexer()
    # corregir el simplex inicial
    ValoresDePartida = CEFeJsToXs(ParametrosCEFAAjustarTupla,ParametrosJsAAjustarTupla)
    maxeval=30000
    tmax=180
    res = optimize(fun_ajst, ValoresDePartida,
        method = NelderMead(initial_simplex = MatlabSimplexer()), 
        f_calls_limit = maxeval, iterations = maxeval, time_limit = tmax)
    #= Otro metodo
    # Valores de los limites inferiores seran los valores iniciales menos 0.1
    lowerbond = [ 0. , -2.0 ]
    # Valores de los limites superiores seran los valores iniciales mas 0.1
    upperbond = [ 8. , 0.0 ]
    res = optimize(fun_ajst, ValoresDePartida,
        method =ParticleSwarm(; lower = lowerbond,  upper = upperbond,  n_particles = 10), 
        f_calls_limit = maxeval, iterations = maxeval, time_limit = tmax)
    =#           

    CEFNuevo, JsNuevo = XsToCEFeJs(Optim.minimizer(res))
    CEFA = merge(CEFNuevo,ParametrosCEFANoAjustarTupla)
    trocas = merge(JsNuevo,ParametrosJsANoAjustarTupla)
    println("\n Ajuste:")
    show(res)
else
    CEFA = merge(ParametrosCEFAAjustarTupla,ParametrosCEFANoAjustarTupla)
    trocas = merge(ParametrosJsAAjustarTupla,ParametrosJsANoAjustarTupla)
end

#################################################################
# resultados
#################################################################
include("Resultados.jl")
