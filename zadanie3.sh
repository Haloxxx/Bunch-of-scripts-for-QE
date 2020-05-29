#!/bin/bash

PSEUDO_DIR='./'                         # Zdefiniowanie folderu z pseudopotencjałem
OUT_DIR='./zadanie3_out'                         # Zdefiniowanie folderu dla plików z wynikami
N_PROC=1

Epsi=48
Erho=$((8*$Epsi))


for cdm in {1000..1040..1}
do

calc_name_prefix='Zadanie3.'$Epsi'.'$cdm         # Zdefiniowanie prefixu obliczeń
input_file=$calc_name_prefix'.in'       # Zdefiniowanie nazwy pliku wsadowego dla programu pw.x z pakietu QE 
output_file=$calc_name_prefix'.out'     # Zdefiniowanie pliku z wynikami
echo $calc_name_prefix

cdm_val=`echo $cdm/100|bc -l`

cat > $input_file << EOF
&control
        calculation = 'scf'             ! Typ obliczeń - scf
        restart_mode = 'from_scratch' ,
        prefix = 'silicon' ,
        tstress = .true. ,
        tprnfor = .true. ,
        pseudo_dir = '$PSEUDO_DIR' ,    ! Wykorzystanie zmiennej z nazwą folderu z pseudopotencjłami
        outdir = '$OUT_DIR$cdm/' ,     ! Stworzenie nazwy dla plików wyjściowych
/
&system
        ibrav = 2 ,
        celldm(1) = $cdm_val , 
        nat = 2 ,
        ntyp = 1 ,
        nbnd = 10 ,
        ecutwfc = $Epsi ,               ! Wpisanie w teks pliku wejściowego Epsi
        ecutrho = $Erho ,
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

for cdm in {1000..1040..1}
do

cdm_val=`echo $cdm/100|bc -l`

file='Zadanie3.'$Epsi'.'$cdm'.out'

energy=`grep ! $file`
energy=${energy:37:11}

text=`grep "highest occupied" $file`

high=${text:$[57*(i+1)+2*6*i+1*i+4*i]:6}
low=${text:$[67*(i+1)+6*i+i*1]:6}

result=`echo $low-$high | bc -l`

echo 'cdm(1) = '$cdm_val' Total energy: '$energy' Band gap: ' $result
echo 'cdm(1) = '$cdm_val' Total energy: '$energy' Band gap: ' $result >> zadanie3.out

done
