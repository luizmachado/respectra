#################################################################
# Rodada Aux para optimizar
#################################################################
function XsToCEFeTrocas(x)
    CEFX = ( B20 = x[1], B40 = x[2] )
    #trocas0 = (J1 = x[10], J2 = x[11], QTbTb = x[12])
    return (CEF = CEFX,)
end

function CEFeTrocasToXs(CEF, trocas)
    x = [ CEF.B20 CEF.B40 ]
    return x
end

function fun_ajst(x)
    CEFAux = XsToCEFeTrocas(x)
    CEFA = merge(CEFAux.CEF, (B43 = CEF0.B43, B60 = CEF0.B60, B63 = CEF0.B63, B66 = CEF0.B66, B4M3 = CEF0.B4M3, B6M3 = CEF0.B6M3, B6M6 = CEF0.B6M6))
    Rodada_Aux_CsT = Ajst_CsT(CEF0 , trocas0, Dados_ExpCsT )
    Rodada_Aux_MT1 = Ajst_Chi(CEFA , trocas0, Dados_Exp1MT )
    Rodada_Aux_MT2 = Ajst_Chi(CEFA , trocas0, Dados_Exp2MT )
    Rodada_Aux_MH1 = Ajst_Mag(CEF0 , trocas0, Dados_Exp1MH )
    Rodada_Aux_MH2 = Ajst_Mag(CEF0 , trocas0, Dados_Exp2MH )
    #=
    println(Rodada_Aux_CsT.Qualid_Ajst * Dados_ExpCsT.Peso_Ajs )
    println(Rodada_Aux_MT1.Qualid_Ajst * Dados_Exp1MT.Peso_Ajs )
    println(Rodada_Aux_MT2.Qualid_Ajst * Dados_Exp2MT.Peso_Ajs )
    println(Rodada_Aux_MH1.Qualid_Ajst * Dados_Exp1MH.Peso_Ajs )
    println(Rodada_Aux_MH2.Qualid_Ajst * Dados_Exp2MH.Peso_Ajs )
    =#
    return Rodada_Aux_MT1.Qualid_Ajst * Dados_Exp1MT.Peso_Ajs + 
           Rodada_Aux_MT2.Qualid_Ajst * Dados_Exp2MT.Peso_Ajs +
           Rodada_Aux_CsT.Qualid_Ajst * Dados_ExpCsT.Peso_Ajs +
           Rodada_Aux_MH1.Qualid_Ajst * Dados_Exp1MH.Peso_Ajs + 
           Rodada_Aux_MH2.Qualid_Ajst * Dados_Exp2MH.Peso_Ajs 
end

#= valores inicias para o ajuste
CEF0 = (B20 = 0.49, B40 = -0.00023, B43 = -0.077, B4M3 = 0., 
        B60 = 0.00006, B63 = 0.0018, B66 = -0.00008, B6M3 = 0., B6M6 = 0. )
trocas0 = (J1 = 2. * 0.65, J2 = 0., QTbTb = 2. * 0.00023)
show(SpinesEInteracoes(CEF0 , trocas0).SitioEInt)
exit()
=#

#leo valores iniciales del archivo SoloParametros.txt
#using Pkg; Pkg.add("JSON")
using JSON

# Abrir o arquivo e ler o conteúdo
ArchPar = open("SoloParametros.txt", "r")
texto = read(ArchPar, String)
close(ArchPar)

# Converter o texto JSON em um dicionário Julia
parametros = JSON.parse(texto)

# Acessar os valores dos parâmetros pelo nome
B20 = parametros["B20"]
B40 = parametros["B40"]

# Fazer algo com os valores dos parâmetros
#println("B20 =", B20)
#println("B40 =", B40)
CEF0 = (B20 = parametros["B20"], B40 = parametros["B40"], B43 = parametros["B43"], B4M3 = parametros["B4M3"],
        B60 = parametros["B60"], B63 = parametros["B63"], B66 = parametros["B66"], B6M3 = parametros["B6M3"], B6M6 = parametros["B6M6"])

trocas0 = (J1 = parametros["J1"], J2 = parametros["J2"], QTbTb = parametros["QTbTb"])
println("\n Interacciones0:")
show(trocas0)
println("")
