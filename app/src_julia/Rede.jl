#################################################################
# Import Rede
#################################################################

# Definição das coordenadas da célula-base considerada no cálculo;
# Total de 2 momentos
celula = [1 , 1 , 1] 
# Parâmetros de rede do cristal;
REa = REb = 7.2794 ; REc = 27.3975
# Vetor de translação da célula; Vectores primitivos
VecPrim = [ REa * [1   0   0];
            REb * [cos(120 / 360 * (2 * pi))  sin(120 / 360 * (2 * pi))   0];
            REc * [0   0   1] ]
# Posição dos spins na célula-Base;
AtomosBase = [ 0.  0.  0. ; 0.   0.   1. / 2.]
# Vizinhos. Sempre a origem se refer a um atomo da base
# [ origem destino          ]
# [ base1  TX2 TY2 TZ2 base2]
# Las dos primeras lineas son de 1ros vec, las ultimas 2 de segundos vec (que coinciden con el sitio)
PrimerosVec= [ 1 0 0  0 2 ; 
               2 0 0  0 1 ; 
               1 0 0  0 1 ; 
               2 0 0  0 2 ; ]
Posiciones = DefinoPosiciones(celula, VecPrim, AtomosBase) 
#SoloPosicionesAtomos = vcat(Posiciones[:,6]...) ;

PrimVec = VecinosConVec(Posiciones, celula, PrimerosVec)

TablaValMedSpines = zeros(size(AtomosBase)[1] * celula[1] * celula[2] * celula[3], 3)

TablaValorMedioO20 = zeros(size(TablaValMedSpines)[1], 1)


function HEfetivoSitio(Bmag, OpsJ, Interacciones, TablaValMedSpines,TablaValorMedioO20)
    # no podemos poner el productor escalar J.B porque [Jx Jy Jz ] no es un vector de 3 matrices
    BEfetivo = SomaSpinsVecinosXJs(TablaValMedSpines, Interacciones)
    O20Efetivo = SomaO20VecinosXO20s(TablaValorMedioO20, Interacciones)
    HEfetivo = (OpsJ.B20 + O20Efetivo) * OpsJ.O20 + 
               OpsJ.B40 * OpsJ.O40 + OpsJ.B43 * OpsJ.O43 + 
                                     OpsJ.B4M3 * OpsJ.O4M3 +
               OpsJ.B60 * OpsJ.O60 + OpsJ.B63 * OpsJ.O63 + OpsJ.B66 * OpsJ.O66 + 
                                     OpsJ.B6M3 * OpsJ.O6M3 + OpsJ.B6M6 * OpsJ.O6M6 + 
            ( OpsJ.gJ * miB * Bmag[1] + BEfetivo[1] ) * OpsJ.Jx + 
            ( OpsJ.gJ * miB * Bmag[2] + BEfetivo[2] ) * OpsJ.Jy + 
            ( OpsJ.gJ * miB * Bmag[3] + BEfetivo[3] ) * OpsJ.Jz 
    return  HEfetivo
end

#Tb
JMomMag = 6.
JTb = OperadoresDeSpin(JMomMag) 
gJTb = 1.5

# Hay dos tipos de sitios en una red honeycomb. El CEF esta rotado 120 entre ellos.
TablaDopage = [ 1 ;  2 ];

function InterSegunVec(trocas, sit1, sit2)
	if sit1 == sit2
		return trocas.J2
	else
		return trocas.J1
	end 
end


function SpinesEInteracoes(CEF , trocas)
    TipoTb1 = merge(JTb, CEF, (gJ = gJTb ,) );
    #El sitio 2 esta relacionado con el 1 por el plano de refleccion bc. Solo cambian de signo B6-6 y B6-3
    CEF2 = (B20 = CEF.B20, B40 = CEF.B40, B43 = CEF.B43, B4M3 = CEF.B4M3, 
            B60 = CEF.B60, B63 = CEF.B63, B66 = CEF.B66, B6M3 = -CEF.B6M3, B6M6 = -CEF.B6M6 )

    TipoTb2 = merge(JTb, CEF2, (gJ = gJTb ,) );
    SpinesEnRed = [ TipoTb1 TipoTb2 ];
    SitioEInt = [ (Sitio = i, Tipo = TablaDopage[i], 
            VEI = (Vecinos = PrimVec[i] , Interacciones = [ (Hei = InterSegunVec(trocas, i, j), Q20 = trocas.QTbTb)  for  j in eachindex(PrimVec[i]) ] ) ) for i in eachindex(PrimVec) ];
    return (SpinesEnRed = SpinesEnRed, SitioEInt = SitioEInt )
end
