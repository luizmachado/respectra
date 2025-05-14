
function SpinesEInteracoes(CEF , trocas)
    # Sitio tipo Mn, com CEF e trocas propias. Estes parametros sao leidos do arquivo SoloParametros.json
    Tipo1 = merge(JOp, (gJ = gJMoment ,) );
    # Esta variable contem ambos tipos de spines
    SpinesEnRed = [ Tipo1 ]

    # Esta variable contem as interacoes resultantes dos sitios e entre os sitios e o tipo de spin.
    #direccionB = [0., 0., 1. ]; direccionB = direccionB / norm(direccionB); Bmodulo = 0.3;
    #Bexterno = Bmodulo * direccionB # se supone que esta en tesla
    InteraccionesSunny!(sys, trocas, CEF)#, Bexterno)

    LocalVec, DelSitio, Interacciones = sacoPrimerosVecinosEInteraccionesDeSunny(sys)
    if( !isdefined(:PrimerosVec , :Vector) )
            global PrimerosVec = hcat([LocalVec...]...)'
            # creo un hash de vectores para buscar los vecinos de un sitio
            # global hashPrim = [hash(PrimerosVec[k,:]) for k = 1:size(PrimerosVec,1)]
            global PrimVec = VecinosConVec(Posiciones, celula, PrimerosVec)
    end
    #println("PrimerosVec:")
    #show(PrimerosVec)
    # funcion que busca los vecinos y las interacciones de un sitio
    function VecinosEInteracciones(i)
            Vecinos = PrimVec[i]
            basedei = Posiciones[i,5]
            onsite = DelSitio[basedei]
            nroinicio = findfirst(x-> x == basedei, PrimerosVec[:,1])
            Bilineares = []
            for nrovecino in eachindex(Vecinos)
                    Bilinear =  Interacciones[nroinicio + nrovecino-1]  #[ Interacciones[BuscoBilinear(i,j)] for  j in Vecinos ]
                    #println("nroinicio:", nroinicio, "nrovecino:", nrovecino, "Vecinos[nrovecino]:", Vecinos[nrovecino], "Bilinear", Bilinear  )
                    push!(Bilineares, Bilinear)
            end
            #println("Vecinos:", Vecinos, "Bilineares:", Bilineares)
            return (Vecinos = Vecinos, onsite = onsite, Bilineares = [Bilineares...])
    end
    
    #Posiciones[i,5] es el numero del atomo de la base
    SitioEInt = [ (Sitio = i, Tipo = TablaDopage[i], VEI = VecinosEInteracciones(i) ) for i in eachindex(PrimVec) ] ;
    #println("SitioEInt:")
    #show(SitioEInt)
    return (SpinesEnRed = SpinesEnRed, SitioEInt = SitioEInt )
end


function sacoPrimerosVecinosEInteraccionesDeSunny(sys::System)
    PrimerosVecinos = []
    Interacciones = []
    DelSitio = []
    for sitio in sys.interactions_union
            onsite = sitio.onsite
            push!(DelSitio, onsite)
            #println("sitio ", sitio)
            for par in sitio.pair
                    # junto en formato campo medio
                    inicial = par.bond.i
                    final = par.bond.j
                    trans = par.bond.n
                    push!(PrimerosVecinos, [inicial,trans[1],trans[2],trans[3],final])
                    interaccion = par.bilin
                    push!(Interacciones, interaccion)
            end
    end
    #CampoMagneticoExterno = []
    #for campo in sys.extfield
    #        push!(CampoMagneticoExterno, campo)
    #end
    return PrimerosVecinos, DelSitio, Interacciones #, CampoMagneticoExterno
    end


# Definimos o Hamiltoniano de cada sitio. 
# O "BEfetivo" é a soma dos campos magneticos dos vizinhos veces sua troca, e dizer que leva em conta as interacoes.
# O "HEfetivo" é o Hamiltoniano de cada sitio, que leva em conta o campo externo, as interacoes e o campo cristalino. Neste caso o CEF so esta representado com um termo B20*O20. 
# OpsJ.CEF tiene el elemento correspondiente a "DelSitio" 
function HEfetivoSitio(Bmag, OpsJ, Interacciones, TablaValMedSpines, TablaValorMedioO20)
    # no podemos poner el productor escalar J.B porque [Jx Jy Jz ] no es un vector de 3 matrices
    BEfetivo = SomaSpinsVecinosXBilinearesSunny(TablaValMedSpines, Interacciones)
    HEfetivo = Interacciones.onsite + 
                ( OpsJ.gJ * miB * Bmag[1] + BEfetivo[1] ) * OpsJ.Jx + 
                ( OpsJ.gJ * miB * Bmag[2] + BEfetivo[2] ) * OpsJ.Jy + 
                ( OpsJ.gJ * miB * Bmag[3] + BEfetivo[3] ) * OpsJ.Jz    
    return  HEfetivo
    end


function SomaSpinsVecinosXBilinearesSunny(TablaValMedSpines, VEI)
    #show(VEI)
    return sum( VEI.Bilineares[i] * TablaValMedSpines[VEI.Vecinos[i],:] for i in eachindex(VEI.Vecinos) )
    end

# Define a rede e as interacoes entre os sitios
