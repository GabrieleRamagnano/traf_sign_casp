#!/bin/bash

#Remember: some functions need to have export-variables
# split_line: export var :: input
# compose: export var :: args

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
    _input_s[idx]+="${line:$start:$end}"           #;echo "${line:$start:$end}" 
}

function compose 
{
    local -n arg_s=$1

    args=""
    for elem in "${arg_s[@]}"; do
        args="$args ""${elem}"
    done
}

function search
{
    local place=$1
    local item=$2

    ls "${place}" | 
    while read -r line; do
          if [[ "${line}" == *"${item}"* ]]; then
             return 0   
          fi
    done
    return 1
}

function set_output { search $1 $2 && rm -r $2; }

function reorder_result
{
    local root=$1
    local out=$2
    local lines=""
    local -i start=0
    local -i holder=0
    
    set_output "${root}" "${out}"
    while read -r line; do lines="${lines}${line}"; done; lines="${lines}stop" 
    until [[ "${lines:$holder:4}" == "stop" ]]; do 
          if [[ "${lines:$holder:1}" == *" "* && $holder -gt $start ]]; then 
             end=$(($holder - $start)) 
             echo "${lines:$start:$end}" >> "${out}" 
             start=$(($holder+1))  
          fi 
          ((holder++))
    done
    end=$(($holder - $start)) 
    echo "${lines:$start:$end}" >> "${out}" 
}

function get_parameters
{
    local -n _param_s=$2

    #prepare function's parameters
    split_line $1 _param_s
}

#interface
function aux
{
    local func=$1
    local -a param_s

    get_parameters $2 param_s
    case "${func}" in split_line) split_line $2 input;;
                      search) search "${param_s[0]}" "${param_s[1]}";;
                      set_output) set_output "${param_s[0]}" "${param_s[1]}";;
                      compose) compose param_s;;
                      reorder_result) reorder_result "${param_s[0]}" "${param_s[1]}";;
                      *) echo "function not found!"
                    
    esac
}

shopt -s lastpipe
aux $@