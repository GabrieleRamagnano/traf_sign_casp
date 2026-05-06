#!/bin/bash
declare root=$1
declare dir=$2
declare label=$3
declare unknown_inst=$4
declare dotunkw_inst=$5
declare task="../../../Results_experiments/Task1/bounds.csv" 
declare utility="../aux0.sh"
declare fst_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total"


function search
{
    local place=$1
    local item=$2

    tree "${place}" -i -f | 
    while read -r line; do
          if [[ "${line}" == *"${item}"* ]]; then
             return 0   
          fi
    done
    return 1
}

function is_there
{
    local -n _asp_output=$1
    local inst_=$2
    local -i len

    len="${#dir}"
    if  search "." "${dir}${inst_:len+2}"; then
        _asp_output="${dir}${inst_:len+2}"
        return 0
    else
        return 1
    fi
}

function clean_file
{
    bash "${utility}" search ".,${unknown_inst}" && rm -r "${unknown_inst}"
    bash "${utility}" search ".,${dotunkw_inst}" && rm -r "${unknown_inst}"; printf "$fst_line"$'\n' > "${dotunkw_inst}" 
}

function unknown
{
    local asp_output
    local -i len

    local prefix="./Instancesv2_round/sippv2/"
    local len=${#prefix}


    clean_file
    for sufx in "random/" "sipp/" "sippv2/"; do
        tail -n +2 $task | while IFS=',' read -r HORIZON PROBLEM MIN; do
        if [[ "$PROBLEM" == *"_round"* ]]; then
               problem="./Instancesv2_round/${sufx}${PROBLEM:len}" #;echo "${dir}/${problem}_${label}_$HORIZON.txt"
               is_there asp_output "${dir}/${problem}_${label}_$HORIZON.txt" &&
               tail -n +1 "${asp_output}" | while read -r line; do    
                       if [[ "${line}" == *"UNKNOWN"* ]]; then
                          echo "${asp_output}" >> "${unknown_inst}"
                          echo "clingcon,${HORIZON},${root}${dir:1}${problem:1},,,,,,0" >> "${dotunkw_inst}"
                       fi
               done
        fi
        done
    done
 
}

shopt -s lastpipe
unknown
