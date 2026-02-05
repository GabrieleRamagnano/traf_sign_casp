#!/bin/bash 
horizon_s=("600" "660" "720" "780" "840" "900")
label="heuphase"
csv=" ./result/result_det_bound_${label}.csv "
py=" ./inst0.py "
py_=" ./inst1.py "
csv_=" ./../../../Results_experiments/Task1/result_det_bound.csv " 
csv_dot=" ./result/result_det_bound_${label}_dot.csv "
args="${py}""${csv}" 
args_="${py_}""${csv_}""${csv_dot}" 


python3 $args

for horizon in "${horizon_s[@]}"; do 
    python3 $args_ $horizon
done
