#################################################################
# resultados
#################################################################
Rodada_Aux_CsT = Ajst_CsT(CEFA , trocas, Dados_ExpCsT )
Rodada_Aux_MT1 = Ajst_Chi(CEFA , trocas, Dados_Exp1MT )
Rodada_Aux_MT2 = Ajst_Chi(CEFA , trocas, Dados_Exp2MT )
Rodada_Aux_MH1 = Ajst_Mag(CEFA , trocas, Dados_Exp1MH )
Rodada_Aux_MH2 = Ajst_Mag(CEFA , trocas, Dados_Exp2MH )

# Imprimo peso individual de cada ajuste
println("CsT:", Rodada_Aux_CsT.Qualid_Ajst * Dados_ExpCsT.Peso_Ajs)
println("1MT:",Rodada_Aux_MT1.Qualid_Ajst  )
println("2MT:",Rodada_Aux_MT2.Qualid_Ajst )
println("1MH:",Rodada_Aux_MH1.Qualid_Ajst * Dados_Exp1MH.Peso_Ajs )
println("2MH:",Rodada_Aux_MH2.Qualid_Ajst * Dados_Exp2MH.Peso_Ajs )

println("\n CEF:")
show(CEFA)
println("\n Interacciones:")
show(trocas)
#################################################################
# imprimo
#################################################################

# imprimo parametros en archivo si ajuste algun parametro...
if (length(ParametrosCEFAAjustarTupla) + length(ParametrosJsAAjustarTupla) > 0 )
    # Imprimo peso total do ajuste
    println("Peso total:", Optim.minimum(res))
    arch = open("Parametros.txt", "w")
    for field in keys(ParametrosCEFAAjustarTupla)
        val = CEFA[field]
        val0 = ParametrosCEFAAjustarTupla[field]
        @printf(arch, " %s : %.6f =>  %.6f \n", field, val0, val)
    end
    for field in keys(ParametrosJsAAjustarTupla)
        val = trocas[field]
        val0 = ParametrosJsAAjustarTupla[field]
        @printf(arch, " %s : %.6f =>  %.6f \n", field, val0, val)
    end
    #@printf(arch, "Peso total: %.6f ", Optim.minimum(res))
    close(arch)
end

x = Dados_ExpCsT.dados.Temp[1:size(Dados_ExpCsT.dados.Temp)[1] - 1,1]

ImprimoXT("CsT.txt", x, Rodada_Aux_CsT.CsT)
ImprimoXT("MT1.txt", Dados_Exp1MT.dados.Temp, Rodada_Aux_MT1.Suscept)
ImprimoXT("MT2.txt", Dados_Exp2MT.dados.Temp, Rodada_Aux_MT2.Suscept)
ImprimoXT("MH1.txt", Dados_Exp1MH.dados.Field, Rodada_Aux_MH1.Magnetizacion)
ImprimoXT("MH2.txt", Dados_Exp2MH.dados.Field, Rodada_Aux_MH2.Magnetizacion)

# Calcular os resultados
resultadosAuto = calcular_splitting_CEF_inicial(CEFA,trocas)

# Exportar os resultados para um arquivo .txt
exportar_resultados(resultadosAuto)  

#println(TablaTemperaturas)

#bdir =  [0.001, 0.002, 1.]
#Dados_Exp1MT = (Direc_Campo = bdir ./ norm(bdir), Modulo_del_campo = 0.1 , dados = (Temp = Dados_Exp1MT.dados.Temp, )) 
#bdir = [1.001, 1.001, 0.0001]
#Dados_Exp2MT = (Direc_Campo = bdir ./ norm(bdir), Modulo_del_campo = 0.1 , dados = (Temp = Dados_Exp2MT.dados.Temp, ))


ConfSpin_Calc =  calcula_spin(CEFA , trocas, 2., 0.01,  [0 0 1] )
println(ConfSpin_Calc)
ImprimoSpin("ConfSpin_Calc.txt", ConfSpin_Calc)


# Chama a função e imprime o resultado
#Entrop_calc = Calcula_Entrop(CEFA , trocas, Dados_ExpCsT)
#ImprimoXT("Entrop_calc.txt", TablaTemperaturas[1:length(TablaTemperaturas)-1], Entrop_calc)
#CsT_calc = Calcula_CsT(CEFA , trocas, Dados_ExpCsT)
#ImprimoXT("CsT_calc.txt", TablaTemperaturas[1:length(TablaTemperaturas)-1], CsT_calc)

TN_max = encontrar_TN_maximo_cambio_entropia(CEFA , trocas, Dados_ExpCsT)
println("TN = ", TN_max)

(Theta_calc , Const_Curie) = Calcular_Theta(CEFA , trocas, Dados_ExpCsT)
println("Theta = ", Theta_calc)

TN_max = encontrar_TN_maximo_cambio_entropia(CEFA , trocas, Dados_Exp1MT)
println("TN = ", TN_max)

(Theta_calc , Const_Curie) = Calcular_Theta(CEFA , trocas, Dados_Exp1MT)
println("Theta = ", Theta_calc)

(Theta_calc , Const_Curie) = Calcular_Theta(CEFA , trocas, Dados_Exp2MT)
println("Theta = ", Theta_calc)

run(`gnuplot grafico.gnuplot`)
