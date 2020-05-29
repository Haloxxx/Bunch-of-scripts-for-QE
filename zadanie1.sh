#!/bin/bash

PSEUDO_DIR='./'                         # Zdefiniowanie folderu z pseudopotencjałem
OUT_DIR='./out'                         # Zdefiniowanie folderu dla plików z wynikami
E_cut_wfc=(32 36 40 44 48 52 56)        # Zdefiniowanie energii kinetycznych odcięcia dla funkcji falowej
N_PROC=2                                # Zdefiniowanie ilości wykorzystywanych procesorów  

for Epsi in "${E_cut_wfc[@]}" ;
do

calc_name_prefix='Si.scf.'$Epsi         # Zdefiniowanie prefixu obliczeń
input_file=$calc_name_prefix'.in'       # Zdefiniowanie nazwy pliku wsadowego dla programu pw.x z pakietu QE 
output_file=$calc_name_prefix'.out'     # Zdefiniowanie pliku z wynikami
echo $calc_name_prefix

Erho=$((8*$Epsi))                       # Obliczenie warości energii kinetycznej odcięcia dla gęstości łądunku - liniowa zależność 

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

mpirun -np $N_PROC /home/ftis/q-e-qe-6.5/PW/src/pw.x -inp $input_file > $output_file


done


for Epsi in "${E_cut_wfc[@]}";
do

calc_name_prefix='Si.scf.'$Epsi
file=$calc_name_prefix'.out'

energy=`grep ! $file`
energy=${energy:37:11}
#echo $energy

time=`grep 'PWSCF        :' $file`
time=${time:89:6}
#echo $time

echo $energy': '$time's'
echo $energy': '$time's' >> zadanie1.out

done
