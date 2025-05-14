#################################################################
# NO CAMBIAR ESTA PARTE
#################################################################
#import Pkg; using Pkg; Pkg.add("Optim, Dierckx, Shuffle, GR, BenchmarkTools, Distributions, LinearRegression, JSON")
pwd()
cd("/home/luizmachado/Documentos/Dev/ajustes/ajuste_cp_mt_mh/")

#IntegroSunny/

using Sunny#, GLMakie
using LinearAlgebra
include("Funciones/CampoMedioBase.jl");
using .CampoMedio
include("Funciones/FuncionesAuxiliares.jl");
include("Funciones/FuncionesParaSunny.jl");

# Neste exemplo vamos a considerar o composto Mn(1-x)Fe(x)CO3.
# Nao vamos ajustar nenhum parametro. So vamos a ver o efeito da desordem nas propiedades.
#################################################################
# Rede, hamiltoniano y tipo de spin
# Nesta parte se define la red, el hamiltoniano y el tipo de spin
#################################################################
include("Rede.jl")


#################################################################
# Leo los parametros de CEF e Js do archivo JSON. Tambem tem a concentracao de Fe
# Os nomes das trocas e do CEF devem ser os mesmos   no arquivo JSON e na seccao "Rede.jl"
#  cambian el signo entre Sunny y MF: O43,  O4M4, O63, O6M3. (probado con J=5/2 y 7/2)
# Los parametros quedan en CEFA y trocas
#################################################################
include("Funciones/LeoParametrosJSON.jl")

# si queremos ver una configuracion magnetica en particular
dados = (Direc_Campo = [1.001, 0.002, 0.], Temp = 2.2 ,  dados = (Field =  6.988469,));
# dejo vectores al azar en TablaValMedSpines
TablaValMedSpines = 2. .* rand(Float64,(length(sys.dipoles) , 3)) .- 1;
ConfiguracionMagnetica(CEFA, trocas, dados).UltConfSpin


#################################################################
# resultados
# Nesta parte se calcula com a aproximacao de campo medio as propiedades termodinamicas e magneticas desejadas
#################################################################
#include("Resultados.jl")

# imprimo la temperatura de orden simple
#TNSimple = 0.1 * (2 + 2 + 1 + 2) * JMom * (JMom + 1.) / 3.


