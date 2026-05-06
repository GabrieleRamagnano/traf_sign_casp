#!/bin/bash
#rm -r "./results_imprv.txt"  
#rm -r "./results_imprv_inst.txt"

declare inst900="900"
declare -g label
declare -g -a label_s
declare -g tag
declare -g -a tag_s=("OPT_Clingcon105" "OPT_DHXphase105" "OPT_DHXplink105")
declare test_list="../packgs0.csv"
declare root="./heu_105"
declare dir="./result"
declare unknw="./inst1.sh"
declare diff="./inst3.sh"
declare unknown_inst
declare dotunkw_inst

#variable parameters

## -- python utilities -- ##
declare -g py_aggr=" ./inst1.py " # results aggregator
declare -g py_plot="./inst5.py"   # plotter

## -- csv files -- ##
declare -g csv_host_dot # dot-host: after dot-conversion
declare -g csv_ref_dot  # dot-reference: after dot-conversion

# aggregate over horizons
declare horizon_s=("600" "660" "720" "780" "840" "900")
declare -g data_plot="./results_imprv.txt"           # data for the plotter
declare -g data_plot_inst="./results_imprv_inst.txt" # data for the plotter

function add
{
    local -n _arr=$1
    local -i idx

    idx="${#_arr[@]}"
    _arr[idx]+=$2  #;echo "${_arr[@]}"
}

function get_label
{
    tail -n +2 "${test_list}" | 
    while IFS=',' read -r name package _label _tail runtail; do
          if [[ "${tag}" == "${name}" ]]; then label="${_label}"; fi
    done
}

function add_dot
{
    tail -n +2 "${dir}/result_${label}_dot.csv" | 
    while read -r line; do 
          echo "${line}" >> "${dotunkw_inst}"
    done
}

function create_dotunkw
{
    # pick the unknown results
    for t in "${tag_s[@]}"; do
        { tag="${t}"
          get_label
          unknown_inst="${dir}/unknown_${label}.txt"
          dotunkw_inst="${dir}/result_${label}_dotunkw.csv" 
          bash "${unknw}" "${root}" "${dir}" "${label}" "${unknown_inst}" "${dotunkw_inst}"           
          add_dot; } &
    done
}

function lb_pair
{
    for t in "OPT_Clingcon105" "OPT_DHXphase105"; do
        tag="${t}"
        get_label
        add label_s $label
    done
}

#function lb_pair
#{
#    for t in "OPT_DHphase105" "OPT_DHplink105"; do
#        tag="${t}"
#        get_label
#        add label_s $label
#    done
#}

function improvement
{
    lb_pair
    { 
       #dotunkw_inst1="${dir}/result_${label_s[0]}_dotunkw.csv" 
       #dotunkw_inst2="${dir}/result_${label_s[1]}_dotunkw.csv" 
       dotunkw_inst1="${dir}/result_${label_s[0]}_dot.csv" 
       dotunkw_inst2="${dir}/result_${label_s[1]}_dot.csv" 
       improv_inst1="${dir}/result_${label_s[0]}_imprv.csv" 
       improv_inst2="${dir}/result_${label_s[1]}_imprv.csv" 

       bash "${diff}" "${dir}" \
                      "${dotunkw_inst1}" \
                      "${dotunkw_inst2}" \
                      "${improv_inst1}" \
                      "${improv_inst2}"; } 
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
    name="opdhxphs"
    # horizon aggregation
    args="${py_aggr}""${csv_ref_dot}""${csv_host_dot}" 
    for horizon in "${horizon_s[@]}"; do 
        python3 $args $name $horizon "" >> "${data_plot}"
    done
    echo "-------------------------" >> "${data_plot}"

    cat "${data_plot}"
    # instance aggregation
    if [[ $inst900 == "900" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      for k in "p01" "p02" "p03" "p04" "p05"; do
          python3 $args $name "900" $k  >> "${data_plot_inst}"
      done
    fi
    echo "-------------------------" >> "${data_plot_inst}"

}

function plot
{
    name="opdhxphs"
    lb_pair
    echo "${py_plot}" "${data_plot}" "opdhxphs" target "${label_s[1]}"
    python3 "${py_plot}" "${data_plot}" "opdhxphs" target "${label_s[1]}"
}

shopt -s lastpipe
"$@"




