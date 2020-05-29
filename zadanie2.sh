#!/bin/bash

PSEUDO_DIR='./'
OUT_DIR='./out'

Epsi=48
Erho=$((8*$Epsi))

input_file='Si.scf.48.out'

cat > $input_file << EOF
&control
        calculation = 'scf'             ! Typ obliczeń - scf
        restart_mode = 'from_scratch' ,
        prefix = 'silicon' ,
        tstress = .true. ,
        tprnfor = .true. ,
        pseudo_dir = '$PSEUDO_DIR' ,    ! Wykorzystanie zmiennej z nazwą folderu z pseudopotencjłami
        outdir = '$OUT_DIR$Epsi/' ,     ! Stworzenie nazwy dla plików wyjściowych
/
&system
        ibrav = 2 ,
        celldm(1) = 10.20 , 
        nat = 2 ,
        ntyp = 1 ,
        nbnd = 10 ,
        ecutwfc = $Epsi ,               ! Wpisanie w teks pliku wejściowego Epsi
        ecutrho = $Erho ,               ! Wpisanie w teks pliku wejściowego Erho
/
&electrons
        diagonalization = 'david' ,
        mixing_mode = 'plain' ,
        mixing_beta = 0.7 ,
        conv_thr =  1.0d-8 ,
/
ATOMIC_SPECIES
Si  28.086  Si.pbe-n-rrkjus_psl.1.0.0.UPF ! Nazwa pseugopotencjału
ATOMIC_POSITIONS
Si 0.00 0.00 0.00
Si 0.25 0.25 0.25
K_POINTS
10
0.1250000  0.1250000  0.1250000   1.00
0.1250000  0.1250000  0.3750000   3.00
0.1250000  0.1250000  0.6250000   3.00
0.1250000  0.1250000  0.8750000   3.00
0.1250000  0.3750000  0.3750000   3.00
0.1250000  0.3750000  0.6250000   6.00
0.1250000  0.3750000  0.8750000   6.00
0.1250000  0.6250000  0.6250000   3.00
0.3750000  0.3750000  0.3750000   1.00
0.3750000  0.3750000  0.6250000   3.00
EOF



for i in {1..4}
do

mpirun -np $i ~/q-e-qe-6.5/PW/src/pw.x -inp $input_file > 'Si.scf.48.'$i'.out'

done

for i in {1..4}
do

file='Si.scf.48.'$i'.out'

time=`grep 'PWSCF        :' $file`
time=${time:$[39+50*(i-1)+(i-1)]:6}
echo $time
echo $time >> zadanie2.out

done
