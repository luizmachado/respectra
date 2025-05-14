#################################################################
# Import Rede
#################################################################

ErNi3Al9 = Crystal("ErNi3Al9.cif"; symprec=1e-5)
cryst = subcrystal(ErNi3Al9, "Er1")
#using GLMakie
#view_crystal(cryst; refbonds = [Bond(1,2,[0,0,0]),  Bond(1,1,[1,0,0]), Bond(1,1,[0,0,1]),Bond(1,1,[1,0,1]),   Bond(2,3,[0,0,1]), Bond(2,3,[1,0,0]), Bond(2,3,[0,0,0]), Bond(2,4,[0,0,0])] ) #necesita GLMakie
print_symmetry_table(cryst, 3.5)
# Para Ho
        JMom = 8;
        L = 6;
        S = 2;
#= Para Yb
        JMom = 7/2;
        L = 3;
        S = 1/2; =#
#= Para Ce
        JMom = 5/2;
        L = 3;
        S = 1/2; =#

# factor giromagnetico efectivo para el homogeneo
geff = 1. + (JMom * (JMom + 1.) - L * (L + 1.) + S * (S + 1.)) / (2. * JMom * (JMom + 1.))
sys = System(cryst, (1, 1, 1), [SpinInfo(1, S=JMom, g=geff)], :SUN) #, seed=2 :dipole :SUN :dipole_large_S

O = stevens_matrices(spin_label(sys, 1));

function InteraccionesSunny!(sys::System, trocas, CEF)
        J0 = trocas.J1 #* I + 0. * dmvec([0.,0.,1.])
        set_exchange!(sys, J0, Bond(1,2,[0,0,0]))
        J1 = trocas.J2 #* I  + 0. * dmvec([0.,0.,1.])
        set_exchange!(sys, J1, Bond(1,1,[1,0,0]))
        
        
        # CEF
        set_onsite_coupling!(sys, CEF.B20 * O[2,0] +  CEF.B40 * O[4,0]+  CEF.B4M3 * O[4,-3]+  CEF.B43 * O[4,3]+  CEF.B60 * O[6,0]+  CEF.B63 * O[6,3]+  CEF.B66 * O[6,6]+  CEF.B6M3 * O[6,-3]+  CEF.B6M6 * O[6,-6], 1)
        #set_external_field!(sys, Bexterno) # no necesito el Bexterno, lo uso como homogeneo.
        return 
    end
    
    

# A partir de aca es automatico
#Mn ; SUN en sunny solo funciona con espin homogeneo (ver 5.8)
JMomMag = (first(sys.Ns) - 1 )/2.
JOp = OperadoresDeSpin(JMomMag);
gJMoment = first(sys.gs)[1,1];

celula = [sys.latsize...];
AtomosBase = [ reduce(hcat, svector ) for svector in sys.crystal.positions];
AtomosBase = [AtomosBase...];
AtomosBase = reduce(vcat, AtomosBase);
VecPrim = sys.crystal.latvecs;

# veo las interacciones (solo bilineales) y las llevo al formato de campo medio.
# saco los parametros de sys generado por SUNNY
################################################
# Nao mexer nesta parte
Posiciones = DefinoPosiciones(celula, VecPrim, AtomosBase) ;
TablaValMedSpines = zeros(size(AtomosBase)[1] * celula[1] * celula[2] * celula[3], 3);
TablaValorMedioO20 = zeros(size(TablaValMedSpines)[1], 1);
# los Mn estan identificados com o numero "1"
# Acotacao: "0" identifica sempre uma vacancia.
TablaDopage = ones(Integer, size(Posiciones)[1]);
################################################
