#!/bin/bash 
horizon_s=("600" "660" "720" "780" "840" "900")
name=$1
label=$2
csv=" ./result/result_${label}.csv "
py=" ./inst0.py "
py_=" ./inst1.py "
csv_=" ./../../../Results_experiments/Task1/result_det_bound.csv " 
csv_dot=" ./result/result_${label}_dot.csv "
args="${py}""${csv}" 
args_="${py_}""${csv_}""${csv_dot}" 

python3 $args $label

for horizon in "${horizon_s[@]}"; do 
    python3 $args_ $name $horizon ""
done

if [[ $3 == "900" ]]; then
   echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
   for k in "p01" "p02" "p03" "p04" "p05"; do
       python3 $args_ $name "900" $k
   done
fi
