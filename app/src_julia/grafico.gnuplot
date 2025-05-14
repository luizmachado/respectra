set terminal pdf enhanced color
set output "AjusteTb139.pdf"
#set key b r
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



#archivos con los datos
archExpMT1="Tb139/1MT.d"
archExpMT2="Tb139/2MT.d"

#archivo con los ajustes
archMT1="MT1.txt"
archMT2="MT2.txt"

ctec=(0.5586*(3./2.)*(3./2.)*0.67*6.*7.)/3.

set multiplot layout 1,2

# grafico M/H
set title "MsHvsT"
set xlabel "Temp[K]"
set ylabel "Chi[emu/mol.Oe]"
plot archExpMT1 u 1:2 skip 5 w p lc 1  t "1MT",\
     archMT1 u 1:2 w l lc 1 t "", \
     archExpMT2 u 1:2 skip 5 w p lc 2 t "2MT" ,\
     archMT2 u 1:2 w l lc 2 t ""
     
set title "1/ChivsT"
set xlabel "Temp[K]"
set ylabel "Chi[emu/mol.Oe]"
plot archExpMT1 u 1:(1/$2) skip 5 w p lc 1  t "1MT",\
     archMT1 u 1:(1/$2) w l lc 1 t "", \
     archExpMT2 u 1:(1/$2) skip 5 w p lc 2 t "2MT" ,\
     archMT2 u 1:(1/$2) w l lc 2 t "" 
     
unset multiplot