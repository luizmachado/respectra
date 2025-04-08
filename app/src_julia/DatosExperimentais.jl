
#################################################################
# Import Datos Experimentais
#################################################################

using LinearAlgebra
using DelimitedFiles

# datos de calor especifico
#nome do arquivo
CpH = "Tb139/1CpH.d" 
# carrega os dados ignorando as primeiras linhas
MatrixCpH = readdlm(CpH, '\t', skipstart=5)
# invierto los datos para que comiencen en temperatura alta
xcp = reverse(MatrixCpH[:,1])
ycp = reverse(MatrixCpH[:,2])

# datos de susceptibilidad magnetica
MT1 = "Tb139/1MT.d" 
Matrix1MT = readdlm(MT1, '\t', skipstart=5)
MT2 = "Tb139/2MT.d" 
Matrix2MT = readdlm(MT2, '\t', skipstart=5)
# invierto los datos para que comiencen en temperatura alta
x1 = reverse(Matrix1MT[:,1])
y1 = reverse(Matrix1MT[:,2])
x2 = reverse(Matrix2MT[:,1])
y2 = reverse(Matrix2MT[:,2])

# datos de magnetizacion
MH1 = "Tb139/1MH.d" 
Matrix1MH = readdlm(MH1, '\t', skipstart=5)
MH2 = "Tb139/2MH.d" 
Matrix2MH = readdlm(MH2, '\t', skipstart=5)
x3 = Matrix1MH[:,1]
y3 = Matrix1MH[:,2]
x4 = Matrix2MH[:,1]
y4 = Matrix2MH[:,2]


# transformo datos leidos en variables a ajustar
# Direccion del campo: Bx,By,Bz
# Modulo del campo [T]
# peso
# Ajusto Susceptibilidad(1) o Mag (0),Ajusto 1/chi(1) o chi
# Dados Experimentais e Cabeçalho
# Uso como peso para el ajuste el valor promedio de los datos de cada medicion.
using Statistics
peso = ( 1. / mean(ycp) )^2
bdir = [0.001, 0.002, 1.]
Dados_ExpCsT = (Direc_Campo = bdir ./ norm(bdir)  , Modulo_del_campo = 0.1 , Peso_Ajs = peso , Tipo_Ajs = "Cp" , dados = (Temp = xcp , Cp = ycp))
peso = 1.0
bdir =  [0.001, 0.002, 1.]
Dados_Exp1MT = (Direc_Campo = bdir ./ norm(bdir), Modulo_del_campo = 0.1 , Peso_Ajs = peso , Tipo_Ajs = "M/H" , dados = (Temp = x1 , Chi = y1)) 
peso = 0.1
bdir = [1.001, 1.001, 0.0001]
Dados_Exp2MT = (Direc_Campo = bdir ./ norm(bdir), Modulo_del_campo = 0.1 , Peso_Ajs = peso , Tipo_Ajs = "M/H" , dados = (Temp = x2 , Chi = y2))
peso = ( 1. / mean(y3) )^2
bdir = [0.001, 0.002, 1.]
Dados_Exp1MH = (Direc_Campo = bdir ./ norm(bdir), Temp = 0.6 , Peso_Ajs = peso , Tipo_Ajs = "M" , dados = (Field = x3 , Mag = y3))
peso = ( 1. / mean(y4) )^2
bdir = [1.001, 1.001, 0.0001]
Dados_Exp2MH = (Direc_Campo = bdir ./ norm(bdir) , Temp = 0.6 , Peso_Ajs = peso , Tipo_Ajs = "M" , dados = (Field = x4 , Mag = y4)) 

