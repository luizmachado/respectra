import Pkg; 
Pkg.add("Dierckx")
Pkg.add("Shuffle")
Pkg.add("GR")
Pkg.add("BenchmarkTools");
Pkg.add("Distributions");
using BenchmarkTools
Pkg.add("LinearRegression")

module CampoMedio
export OperadoresDeSpin, miB, KB, muBemu, muBKsT, 
       DefinoPosiciones, VecinosConVec, SomaSpinsVecinosXJs, 
       SomaO20VecinosXO20s, BarroCampoTemp

using LinearAlgebra
using Random

IMPRIMO = "NO"

"""
    OperadoresDeSpin(dj::Number)
    Crea todos los operadores de spin tipo Stevens para un dado 2J+1.
    Tambien crea Jx,Jy,Jz
"""
function OperadoresDeSpin(dj::Number)
    Nj = Int( 2 * dj + 1 )
    Jz = [ x == y ? x - 1 - dj : 0 for x=1:Nj, y=1:Nj ]
    AUXSP = [ x == y - 1 ? sqrt(( dj + ( y - 1 -dj)) * (dj - ( y - 1 -dj) + 1 )) : 0 for x=1:Nj, y=1:Nj ]
    JP = transpose(AUXSP)
    Iden = Matrix(1.0I, Nj, Nj)
    JM = transpose(JP)
    Jx = (1/2)*(JP + transpose(JP))
    Jy = (- im / 2) * (JP - transpose(JP))
    Jz2 = Jz*Jz;
    Jz4 = Jz2*Jz2;
    Jz6 = Jz2*Jz4;
    JP2 = JP*JP;
    JM2 = transpose(JP2);
    JP4 = JP2*JP2;
    JM4 = transpose(JP4);
    JP6 = JP4*JP2;
    JM6 = transpose(JP6);
    # n = 2
    O20 = 3*Jz2 - dj*(dj + 1)*Iden;
    O22 = (1/2)*(JP2 + JM2);
    O2e = sqrt(3) * (Jy * Jy - Jx * Jx);
    # n = 4
    O40 = 35 * Jz4 - 30 * dj * (dj + 1) * Jz2 + 25 * Jz2 - 
           6 * dj * (dj + 1) * Iden + 3 * (dj * (dj + 1))^2 * Iden;
    O41 = (1/3) * (Jx + Jy + Jz) * (7 * Jz2 * Jz - 3 * dj * (dj + 1) * Jz);
    O42 = (1/4)*((7*Jz2 - dj*(dj + 1)*Iden - 5*Iden)*(JP2 + JM2) + 
           (JP2 + JM2)*(7*Jz2 - dj*(dj + 1)*Iden - 5*Iden));
    O43 = (1/4)*(Jz*(JP2*JP + JM2*JM) + (JP2*JP + JM2*JM)*Jz);
    #Tomado do Hutching, pag. 28
    O4M3 = - im * (1 / 4) * (Jz * (JP2 * JP - JM2 * JM) + (JP2 * JP - JM2 * JM) * Jz);
    O44 = (1/2) * (JP4 +JM4);    
    O4M4 = - im * (1/2) * (JP4 - JM4);    
    # n = 6
    O60 = 231 * Jz6 - 315 * dj * (dj + 1) * Jz4 + 735 * Jz4 + 
          105 * (dj * (dj + 1))^2 * Jz2 - 525 * dj * (dj + 1) * Jz2 +
          294 * Jz2 - 5 * (dj * (dj + 1))^3 * Iden + 40 * (dj * (dj + 1))^2 * Iden - 
          60 * dj * (dj + 1) * Iden;
    O62 = (1/4)*((33*Jz4 - 18*Jz2*dj*(dj+1) - 123*Jz2 + dj^2 *(dj + 1)^2 *Iden + 
          10*dj*(dj + 1)*Iden + 102*Iden)*(JP2 + JM2) + (JP2 + JM2)*(33*Jz4 - 18*Jz2*dj*(dj+1) - 
          123*Jz2 + dj^2 *(dj + 1)^2 *Iden +10*dj*(dj + 1)*Iden + 102*Iden));
    O63 = (1/4)*((11*Jz2*Jz - 3*dj*(dj + 1)*Jz - 59*Jz)*(JP2*JP + JM2*JM) + 
          (JP2*JP + JM2*JM)*(11*Jz2*Jz - 3*dj*(dj + 1)*Jz - 59*Jz));
    O6M3 = (1/4*im)*((11*Jz2*Jz - 3*dj*(dj + 1)*Jz - 59*Jz)*(JP2*JP - JM2*JM) + 
           (JP2*JP - JM2*JM)*(11*Jz2*Jz - 3*dj*(dj + 1)*Jz - 59*Jz));
    O64 = (1/4)*((11*Jz2 - dj*(dj + 1)*Iden - 38*Iden)*(JP4 + JM4) + 
           (JP4 + JM4)*(11*Jz2 - dj*(dj + 1)*Iden - 38*Iden));
    O66 = (1/2)*(JP6 + JM6);
    O6M6 = (1/2*im)*(JP6 - JM6);
    return (Jx = Jx, Jy = Jy,Jz = Jz, 
            O20 = O20, O22 = O22, O2e = O2e, 
            O40 = O40, O42 = O42, O43 = O43, O44 = O44, O4M3 = O4M3, O4M4 = O4M4,
            O60 = O60, O62 = O62, O63 = O63, O6M3 = O6M3, O64 = O64, O66 = O66, O6M6 = O6M6
        ) 
end


"""
    AtomosBaseCartesianos(VecPrim, PosBase)
  Dados los vectores primitivos y los vectores de la base 
  (en terminos de los vectores primitivos) devuelve los
   vectores de la base en coordenadas cartesianas.
"""
function AtomosBaseCartesianos(VecPrim, PosBase) 
    sumo = [ sum( PosBase[n4,i] * VecPrim[i,:] for i = 1:size(VecPrim)[1] )  
                                               for  n4 = 1:size(PosBase)[1] ] 
    sumoFin = [sumo...]
    sumoFinMatrix = reduce(hcat,sumoFin)'
    return sumoFinMatrix
end;

#Posição/localização do íon dentro do vetor posição
"""
    FunPosiciones(RE1, ns, celula)
    Dada a posição do RE na rede, devolve o indice associado ao vetor de posicoes
"""
function FunPosiciones(RE1, ns, celula)
    Numero = 1 + mod(ns[3] - 1 , celula[3]) + 
            celula[3] * mod( ns[2] - 1 ,celula[2]) +  
            celula[3] * celula[2] * mod( ns[1]- 1 , celula[1]) + 
            celula[3] * celula[2] * celula[1] * (RE1 - 1)
    return Numero
end;

"""
    DefinoPosiciones(celula, VecPrim, AtomosBase)
    Dada a celula, os vetores primitivos e os atomos
     da base,cria um vetor com as posições dos momentos magneticos (as RE).
     Utiliza a Translação da posição do RE na rede;
"""
function DefinoPosiciones(celula, VecPrim, AtomosBase)
   PosSpinDeBaseCart = AtomosBaseCartesianos(VecPrim, AtomosBase)
   PosicoesRE = [ [FunPosiciones(n4, [n1 , n2, n3], celula), n1 , n2 , n3, n4  , 
                   PosSpinDeBaseCart[n4,:] + 
                   (n1 - 1) * VecPrim[1,:] + (n2 - 1) * VecPrim[2,:] + (n3 - 1) * VecPrim[3,:] 
        ]
                  for n1 = 1:celula[1], n2 = 1:celula[2], n3 = 1:celula[3], n4 = 1:size(PosSpinDeBaseCart)[1] ]
   # Posição dos RE na rede reorganizadas; Pasa de vetor de vetores 
   PosicoesFinaisRE = [PosicoesRE...]
   PosicoesFinaisREMatrix = reduce(hcat,PosicoesFinaisRE)'
   # ordeno las posiciones por el valor de FunPosiciones
   PosicoesFinaisRE = PosicoesFinaisREMatrix[sortperm(PosicoesFinaisREMatrix[:, 1]), :]
   return PosicoesFinaisRE
end;

"""
    VecinosConVec(Posiciones, celula, VecVecinos)
    Dadas as posições dos momentos magneticos, a celula e um vetor, 
    encontra todos os vezinhos cujas posicoes difierem em esse vetor.
TBW
"""
function VecinosConVec(Posiciones, celula, VecVecinos)
    TVecinos = Vector{Vector{Int}}();
    for origen in eachrow(Posiciones)
        NumeroOrigen = FunPosiciones( origen[5], origen[2:4], celula)
        #print( origen, "\n" )
        Vecinos = Vector{Int}()
        for desplazamiento in eachrow(VecVecinos)
            if origen[5] == desplazamiento[1]
                #print( desplazamiento, "\t")
                celda = origen[2:4] + desplazamiento[2:4]
                #print( celda, "\t")
                NumeroVecino = FunPosiciones( desplazamiento[5], celda, celula)
                #print( NumeroVecino, "\t", norm(SoloPosicionesAtomos[NumeroVecino,:] - SoloPosicionesAtomos[NumeroOrigen,:]), "\n")
                push!(Vecinos, NumeroVecino)
                #print( NumeroVecino, "\t" )
            end
        end
        push!(TVecinos, sort(Vecinos))
        #break
    end
    return TVecinos
end;

kB = 8.617333262*10^-5 #* eV / K      https://en.wikipedia.org/wiki/Boltzmann_constant
muB = 5.7883818060 * 10^-5 #* eV / T  https://en.wikipedia.org/wiki/Bohr_magneton
const miB = muB/kB
const KB = 8314.46261815324 #mJ⋅K−1⋅mol−1
const muBemu=0.5586  # muB en emu
const muBKsT=0.671713816 #muB/kB

#Soma das contribuições de todos O20 de todos os Vizinhos (importante para interações quadropolares)
"""
    SomaO20Vecinos(TablaValorMedioO20, Vecinos)
    Suma los espines de los sitios vecinos
"""
function SomaO20Vecinos(TablaValorMedioO20, Vecinos)
   CampoO20Vecinos = sum(TablaValorMedioO20[i] for i = Vecinos)
   return  CampoO20Vecinos
end;

#Soma dos spins de todos os vizinhhos veces sua interacao
"""
    SomaSpinsVecinosXJs(TablaValMedSpines, VEI)
    Soma dos spins de todos os vizinhhos veces sua interacao
"""
function SomaSpinsVecinosXJs(TablaValMedSpines, VEI)
   CampoVecinos = sum(
        VEI.Interacciones[i].Hei * TablaValMedSpines[VEI.Vecinos[i] , :] 
        for i in eachindex(VEI.Vecinos)  )
   return  CampoVecinos
end;


#Soma dos O20 de todos os vizinhhos veces sua interacao
""" 
    SomaO20VecinosXO20s(TablaValorMedioO20, VEI)
    Soma dos O20 de todos os vizinhhos vezes sua interacao
"""
function SomaO20VecinosXO20s(TablaValorMedioO20, VEI)
   CampoO20Vecinos = sum(
        VEI.Interacciones[i].Q20 * TablaValorMedioO20[VEI.Vecinos[i] ] 
        for i in eachindex(VEI.Vecinos)  )
   return  CampoO20Vecinos
end;



"""
    FuncionParticion2(TodoEnergia, T)
    Dadas las energias de un sitio y la temperatura calcula la funcion de particion, la entropia y las probabilidades de cada estado.
"""
function FuncionParticion2(TodoEnergia, T)
   Energias = TodoEnergia .- TodoEnergia[1]
   TablaExpo = [ ( EnerAux/T<200. ? exp(-EnerAux/T) : eps(0.0) )  for EnerAux = Energias ]
   FuncionParticion = sum( Exponenciales for Exponenciales = TablaExpo)
   Probabilidades = 1. / FuncionParticion  * [ Exponenciales for Exponenciales = TablaExpo ]
   Entropia = - sum( ( Prob > eps(0.0) ? Prob * log(Prob) : 0. ) for Prob = Probabilidades)
   if isnan(Entropia)
        println("S NOT A NUMBER! = ", Entropia)
        show(Energias)
        show(TablaExpo)
        show(FuncionParticion)
        show(Probabilidades)
        exit()        
   end
   return  (Z = FuncionParticion, S = Entropia, Pi = Probabilidades)
end;

"""
    ValorMedioOp(Estado, Operador)
    calcula el valor medio del Operador
"""
function ValorMedioOp(Estado, Operador)
   ValorMedioO20 = real(conj(transpose(Estado)) * Operador * Estado)
   return  ValorMedioO20
end;

function ValorMedioTempOp(Estados, FunPart, Operador)
   ValorMedioTempO20 = sum( ValorMedioOp(Estados[: , i], Operador) * FunPart.Pi[i] for i in eachindex(FunPart.Pi) )
   return  ValorMedioTempO20
end;

function NuevoSpinSitio(Interac,  TablaValMedSpines, Temp, TablaValorMedioO20, Bmag, SpinOp, HEff::Function)
    #    HEfetivoSitio = HSitio(Bmag, SpinOp) + 
    #                 HInteraccion(Interac, TablaValMedSpines, TablaValorMedioO20, SpinOp)
    HEfetivo = HEff(Bmag, SpinOp, Interac, TablaValMedSpines,TablaValorMedioO20)
    TodoEnergia = real(eigvals(HEfetivo))
    Estados = eigvecs(HEfetivo)
    FunPart = FuncionParticion2(TodoEnergia, Temp)
    NovoSpin = [ValorMedioTempOp(Estados, FunPart, SpinOp.Jx)  
                ValorMedioTempOp(Estados, FunPart, SpinOp.Jy)  
                ValorMedioTempOp(Estados, FunPart, SpinOp.Jz) ]
    NovoO20 = ValorMedioTempOp(Estados, FunPart, SpinOp.O20)
    return [NovoSpin, FunPart.S, NovoO20]
end;

function ActualizoSpines(TablaValMedSpines, SitioEInt, Temp, TablaValorMedioO20, Bmag, SpinesOp, HEff::Function)
   TotalSpines = size(TablaValMedSpines)[1]
   NuevosSpines = deepcopy(TablaValMedSpines)
   NuevosO20 = deepcopy(TablaValorMedioO20)
   Entropia = 0.
   for i in  1 : TotalSpines
       if SitioEInt[i].Tipo != 0
          SpinAux = NuevoSpinSitio(SitioEInt[i].VEI, NuevosSpines, Temp, NuevosO20, Bmag, SpinesOp[SitioEInt[i].Tipo], HEff)
          NuevosSpines[i , : ] = real(SpinAux[1][:])
          NuevosO20[i] = real(SpinAux[3])
          Entropia += real(SpinAux[2])
          #print(SpinAux[1])
       end
   end
    return  [NuevosSpines, Entropia/TotalSpines, NuevosO20]
end;

function Convergencia(TablaValMedSpines, SitioEInt, ItMax, CutOff, Temp, TablaValorMedioO20, Bmag, SpinesOp, HEff::Function)
   TotalSpines = size(TablaValMedSpines)[1]
   NuevosSpines = deepcopy(TablaValMedSpines)
   NuevosO20 = deepcopy(TablaValorMedioO20)
   Norma = 1.; iteracion = 0;
   SpinAux = ActualizoSpines(NuevosSpines, SitioEInt, Temp, NuevosO20, Bmag, SpinesOp, HEff)
   while iteracion <= ItMax && Norma > CutOff
        SpinAux = ActualizoSpines(NuevosSpines, SitioEInt, Temp, NuevosO20, Bmag, SpinesOp, HEff)
        Norma = sum(norm(NuevosSpines[i , :] - SpinAux[1][i , :]) for i in  1 : TotalSpines)
        iteracion += 1 
        NuevosSpines = deepcopy(SpinAux[1]); NuevosO20 = deepcopy(SpinAux[3])
   end
    
   if iteracion == ItMax && IMPRIMO == "SI"
        print("Convergencia sale por maxima iteracion")
   end
   return  [NuevosSpines, SpinAux[2], NuevosO20]
    #ActualizoSpines tiene la entropia en componente 2
end;

function Magnetizacion(Campo, Spines)
   MagnitudCampo = norm(Campo)
   TotalSpines = size(Spines)[1]
   #si campo=0, devuelve M//z; sino devuelve M
   # El signo (-) es para que acompañe al (+) en el hamiltoniano.
   if MagnitudCampo > 0
          Magnetizacion = - 1. / (TotalSpines * MagnitudCampo) * sum(dot(Spines[i , :] , Campo) for i in  1 : TotalSpines)
   else
          Magnetizacion = - 1. / TotalSpines * sum(dot(Spines[i , :], [0, 0, 1]) for i in  1 : TotalSpines)
   end
   return  Magnetizacion
end;

function MedO20(O20s)
   TotalSpines = size(O20s)[1];
   ValorMedO20 = 1. / TotalSpines * sum(O20s[i] for i in  1 : TotalSpines);
   return  ValorMedO20
end; 

function BarroCampoTemp(Campos, direccionB, Temps, TablaValMedSpines, TablaValorMedioO20, SitioEInt, SpinesOp, HEff::Function)
    RespuestaTermo = Vector{Vector{Float64}}()
    for Bmod in Campos
        Bmag = Bmod * direccionB         
        for Temp in Temps
       #     TablaValMedSpines = TablaValMedSpines + rand(Uniform(-0.1, 0.1), size(TablaValMedSpines)[1], 3)
            TablaValMedSpines = TablaValMedSpines + 0.2 .* ( rand( Float64, size(TablaValMedSpines) ) .- 0.5 )
            NuevosValoresSpines = Convergencia(TablaValMedSpines, SitioEInt, 20, 10^-4, Temp, TablaValorMedioO20, Bmag, SpinesOp, HEff)
            magnetizacion = Magnetizacion(Bmag, NuevosValoresSpines[1])
            valmedO20 = MedO20(NuevosValoresSpines[3])
            push!(RespuestaTermo, [Temp, Bmod, magnetizacion, NuevosValoresSpines[2], valmedO20])
            TablaValMedSpines = NuevosValoresSpines[1]
            TablaValorMedioO20 = NuevosValoresSpines[3]
            #println(Temp, TablaValMedSpines[1:2,:])
        end
            
    end
    ResultadosMat = reduce(hcat, [RespuestaTermo...] )' 

    return (PropTermo = ResultadosMat, UltConfSpin = TablaValMedSpines, UltConfO20 = TablaValorMedioO20)
end


end #FIN DEL MODULO CampoMedio



