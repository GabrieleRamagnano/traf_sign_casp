#!/bin/bash

declare inst900="900"

#variable parameters
## -- python utilities -- ##
declare -g py_aggr=" ./inst1.py " # results aggregator
declare -g py_plot="./inst6.py"   # plotter

## -- csv files -- ##
declare -g csv_host_dot # dot-host: after dot-conversion
declare -g csv_ref_dot  # dot-reference: after dot-conversion

# aggregate over horizons
declare horizon_s=("600" "660" "720" "780" "840" "900")
declare -g data_plot="./results_imprv.txt"           # data for the plotter
declare -g data_plot_inst="./results_imprv_inst.txt" # data for the plotter

function split_line
{
    local line=$1 
    local -n _input_s=$2 
    local -i start=0
    local -i holder=0
    local -i idx
    local ifs=","
    
    line="${line}stop" 
    until [[ "${line:$holder:4}" == "stop" ]]; do 
          if [[ "${line:$holder:1}" == *"${ifs}"* && $holder -gt $start ]]; then 
             end=$(($holder - $start)) 
             idx="${#_input_s[@]}" 
             _input_s[idx]+="${line:$start:$end}" #;echo "${line:$start:$end}" 
             start=$(($holder+1))  
          fi 
          ((holder++))
    done
    end=$(($holder - $start)) 
    idx="${#_input_s[@]}" 
    _input_s[idx]+="${line:$start:$end}"          #;echo "${line:$start:$end}" 
}

function add_dot
{ 
    local lb_=$1

    tail -n +2 "${root_}/${home_}/result_${lb_}_dot.csv" | 
    while read -r line; do 
          echo "${line}" >> "${dotunkw_inst}"
    done
}

function create_dotunkw
{
    # pick the unknown results
    export csv_dot="${root_}/${home_:2}/result_${label}_dot.csv"
    if [[ "${double_enc}" == "true" ]]; then
        export csv_test="${root_}/${home_:2}/result_${enc_test}_${label}_dot.csv"
        export csv_ref="${root_}/${home_:2}/result_${enc_ref}_${label}_dot.csv"
        bash "${split}" 
        for lb in "${enc_test}_${label}" "${enc_ref}_${label}"; do
             export encoding="${lb%'_'$label}"
             echo "${encoding}"
             export unknown_inst="${dir_}/unknown_${lb}.txt"
             export dotunkw_inst="${dir_}/result_${lb}_dotunkw.csv" 
             bash "${unknw}"          
             add_dot "${lb}"
             csv_="${csv_dot%'_'${label}'_dot.csv'}_${lb}_dot.csv"
             bash "${enc_record}" add_file "${csv_}" "${lb}"
        done
    else
         export encoding="${enc_test}"
         export unknown_inst="${dir_}/unknown_${label}.txt"
         export dotunkw_inst="${dir_}/result_${label}_dotunkw.csv" 
         bash "${unknw}"           
         add_dot "${label}"
         bash "${enc_record}" add_file "${csv_dot}" "${label}"
    fi
    
}


function improvement
{
    split_line "$(bash "${get}")" arg_s #;echo "${arg_s[@]}"
    export dotunkw_test="${arg_s[0]}"
    export dotunkw_ref="${arg_s[1]}"
    export lb_test="${arg_s[2]}"
    export lb_ref="${arg_s[3]}"
    export imprv_test="${dir_}/result_${lb_test}_imprv.csv"
    export imprv_ref="${dir_}/result_${lb_ref}_imprv.csv"
    bash "${diff}" 
}

function set_csv
{
    rm -r "./results_imprv.txt"  
    rm -r "./results_imprv_inst.txt"
    lb_pair
    csv_ref_dot=" ${dir}/result_${label_s[0]}_imprv.csv "
    csv_host_dot=" ${dir}/result_${label_s[1]}_imprv.csv " 
}

### -- AGGREGATION PROCESS -- ###
function aggregate
{
    set_csv
    name="pddl"
    refe="cling"
    encoding2="pddl"
    encoding="clingcon"
    # horizon aggregation
    args="${py_aggr}""${csv_ref_dot}""${csv_host_dot}" 
    for horizon in "${horizon_s[@]}"; do 
        python3 $args $name $refe $horizon "" "${encoding}" "${encoding2}" >> "${data_plot}"
    done
    echo "-------------------------" >> "${data_plot}"

    cat "${data_plot}"
    # instance aggregation
    if [[ $inst900 == "900" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      for k in "p01" "p02" "p03" "p04" "p05"; do
          python3 $args $name "900" $k  "${encoding}" "${encoding2}"   >> "${data_plot_inst}"
      done
    fi
    echo "-------------------------" >> "${data_plot_inst}"

}

function plot
{
    nam="cling"
    refe="pddl"
    lb_pair
    echo "${py_plot}" "${data_plot}" "${nam}" target "${label_s[1]}" "${refe}"
    python3 "${py_plot}" "${data_plot}" "${nam}" target "${label_s[1]}" "${refe}"
    
}

shopt -s lastpipe
"$@"




