#################################################################
# resultados calculados sem dados experimentais
#################################################################
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

# Calcular os resultados
resultadosAuto = calcular_splitting_CEF_inicial(CEFA,trocas)

# Exportar os resultados para um arquivo .txt
exportar_resultados(resultadosAuto)  

#Definir um intervalo de temperatura para o cálculo de CsT
TablaTemperaturas = gerar_temperaturas(90, 150, 50);
TablaCampos = gerar_campos(0,15,30)
#println(TablaTemperaturas)
bdir = [0.001, 0.002, 1.]
Dados_ExpCsT = (Direc_Campo = bdir ./ norm(bdir)  , Modulo_del_campo = 0.1 , dados = (Temp = TablaTemperaturas, ))
bdir =  [0.001, 0.002, 1.]
Dados_Exp1MT = (Direc_Campo = bdir ./ norm(bdir), Modulo_del_campo = 0.1 , dados = (Temp = TablaTemperaturas, )) 
bdir = [1.001, 1.001, 0.0001]
Dados_Exp2MT = (Direc_Campo = bdir ./ norm(bdir), Modulo_del_campo = 0.1 , dados = (Temp = TablaTemperaturas, ))
bdir = [0.001, 0.002, 1.]
Dados_Exp1MH = (Direc_Campo = bdir ./ norm(bdir), Temp = 2.0 , dados = (Field = TablaCampos,))
bdir = [1.001, 1.001, 0.0001]
Dados_Exp2MH = (Direc_Campo = bdir ./ norm(bdir), Temp = 2.0 , dados = (Field = TablaCampos,))


#Chama a função para calcular as propriedades
Entrop_calc = Calcula_Entrop(CEFA , trocas, Dados_ExpCsT)
ImprimoXT("Entrop_calc.txt", TablaTemperaturas[1:length(TablaTemperaturas)-1], Entrop_calc)
CsT_calc = Calcula_CsT(CEFA , trocas, Dados_ExpCsT)
ImprimoXT("CsT_calc.txt", TablaTemperaturas[1:length(TablaTemperaturas)-1], CsT_calc)
Chi_calc_1MT = Calcula_Chi(CEFA , trocas, Dados_Exp1MT)
ImprimoXT("MT1_calc.txt", TablaTemperaturas, Chi_calc_1MT)
Chi_calc_2MT = Calcula_Chi(CEFA , trocas, Dados_Exp2MT)
ImprimoXT("MT2_calc.txt", TablaTemperaturas, Chi_calc_2MT)
Mag_calc_1MH = Calcula_Mag(CEFA , trocas, Dados_Exp1MH)
ImprimoXT("MH1_calc.txt", TablaCampos, Mag_calc_1MH)
Mag_calc_2MH = Calcula_Mag(CEFA , trocas, Dados_Exp2MH)
ImprimoXT("MH2_calc.txt", TablaCampos, Mag_calc_2MH)
ConfSpin_Calc =  calcula_spin(CEFA , trocas, 2., 0.01,  [0 0 1] )
println(ConfSpin_Calc)
ImprimoSpin("ConfSpin_Calc.txt", ConfSpin_Calc)

# Chama a função e imprime o resultado
TN_max = encontrar_TN_maximo_cambio_entropia(CEFA , trocas, Dados_ExpCsT)
println("TN = ", TN_max)

(Theta_calc , Const_Curie) = Calcular_Theta(CEFA , trocas, Dados_Exp1MT)
println("Theta = ", Theta_calc)

(Theta, Const_Curie)= Calcular_Theta(CEFA , trocas, Dados_Exp1MT,2600,2500)
print("\n (B par c) Theta=", Theta ,"  ConstCurie=", Const_Curie)

(Theta, Const_Curie)= Calcular_Theta(CEFA , trocas, Dados_Exp2MT,2600,2500)
print("\n (B per c) Theta=", Theta ,"  ConstCurie=", Const_Curie)

run(`gnuplot grafico.gnuplot`)
