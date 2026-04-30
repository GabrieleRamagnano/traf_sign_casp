#!/bin/bash
declare dir=$1
declare dotunkw_inst1=$2
declare dotunkw_inst2=$3
declare improv_inst1=$4
declare improv_inst2=$5
declare utility="../aux0.sh"
declare fst_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total,Diff"

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
    bash "${utility}" search ".,${improv_inst1}" && rm -r "${improv_inst}"; printf "$fst_line"$'\n' > "${improv_inst1}" 
    bash "${utility}" search ".,${improv_inst2}" && rm -r "${improv_inst}"; printf "$fst_line"$'\n' > "${improv_inst2}"
}

function calculate_improvement
{
    local asp_output
    local -i num
   
    num=0
    clean_file
    tail -n +2 "${dotunkw_inst1}" | 
    while IFS=',' read -r enc HOR PROBLEM l1 l2 l3 l4 l5 TOT; do
        tot1=$(echo "$TOT" | bc -l)
        tail -n +2 "${dotunkw_inst2}" | 
        while IFS=',' read -r enc hor problem l1 l2 l3 l4 l5 tot; do
              if [[ "$PROBLEM" == "$problem" && "$HOR" == "$hor" ]]; then
                 tot2=$(echo "$tot" | bc -l)
                 diff=$(echo "($tot2 - $tot1)*100/$tot1" | bc -l) ;echo $diff
                 if (( $(echo "$diff > 0" | bc -l) )); then 
                    echo "${enc},${hor},${PROBLEM},${l1},${l2},${l3},${l4},${l5},${TOT},${diff}" >> "${improv_inst2}"
                 elif (( $(echo "$diff < 0" | bc -l) )); then 
                      diff=$(echo "- $diff" | bc -l)
                      echo "${enc},${hor},${problem},${l1},${l2},${l3},${l4},${l5},${tot},${diff}" >> "${improv_inst1}"
                 fi
             fi
        done
    done

    
 
}

shopt -s lastpipe
calculate_improvement
