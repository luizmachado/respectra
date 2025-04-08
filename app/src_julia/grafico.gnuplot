set terminal pdf enhanced color
set output "AjusteTb.pdf"
unset xtics
unset ytics
unset ztics
arch = "ConfSpin_Calc.txt"

escala = 0.5

set multiplot layout 2,2

set xlabel "x"
set ylabel "y"
set zlabel "z"


sp arch u ($1 - $4/escala/2.):($2 - $5/escala/2.):($3 - $6/escala/2.):  \
         ($4/escala):($5/escala):($6/escala):3    \
         w vectors lc variable lw 3 t ""

unset object 1
unset object 2
unset object 4

set xlabel "x"
set ylabel "z"

p arch u ($1 - $4/escala/2.):($3 - $6/escala/2.):  \
         ($4/escala):($6/escala):3    \
         w vectors lc variable lw 3 t ""

set xlabel "x"
set ylabel "y"

p arch u ($1):($2):  \
         6:3    \
         w p ps variable lc variable lw 3 t ""

set xlabel "y"
set ylabel "z"

p arch u ($2 - $5/escala/2.):($3 - $6/escala/2.):  \
         ($5/escala):($6/escala):3    \
         w vectors lc variable lw 3 t ""


archCsT="CsT_calc.txt"
archEntrop="Entrop_calc.txt"
archMT1="MT1_calc.txt"
archMT2="MT2_calc.txt"
archMH1="MH1_calc.txt"
archMH2="MH2_calc.txt"

ctec=(0.5586*(3./2.)*(3./2.)*0.67*6.*7.)/3.

unset xrange
unset yrange

set multiplot layout 2,2
set xrange [*:*]
set yrange [*:*]
set title  "CsvsT"
set xlabel "Temp[K]"
set ylabel "C/T[mJ/K^2/mol]"
plot archCsT u 1:2 w p lc 1 t ""


#Grafico Entrop vs T 
set title  "EntropvsT"
set xlabel "Temp[K]"
set ylabel "Entrop[mJ/K/mol]"
plot archEntrop u 1:2 w p lc 1 t ""
    

# grafico M/H
set title "MsHvsT"
set xlabel "Temp[K]"
set ylabel "Chi[emu/mol.Oe]"
plot archMT1 u 1:2 w l lc 1 t "",\
     archMT2 u 1:2 w l lc 2 t ""


set title "1/ChivsT"
set xlabel "Temp[K]"
set ylabel "Chi[emu/mol.Oe]"
plot archMT1 u 1:(1/$2) w l lc 1 t "",\
     archMT2 u 1:(1/$2) w l lc 2 t ""



unset multiplot
set title "MvsH"
set xlabel "Field[T]"
set ylabel "Mag[emu/mol]"
plot archMH1 u 1:2 w l lc 1 t "", \
     archMH2 u 1:2 w l lc 2 t ""


