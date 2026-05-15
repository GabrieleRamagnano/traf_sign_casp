#!/bin/bash

declare -g dotunkw_test
declare -g dotunkw_ref
declare -g lb_test
declare -g lb_ref
declare -a arg_s 

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

function check_double
{
    if [[ "${double_encoding}" == "true" ]]; then
        tail -n +2 "${unkn_csv}" | 
        while IFS=',' read -r name_ lb dot_csv unk_csv; do
              if [[ "${name_}" == "${tag_}" && "${lb}" == "${encoding_test}_${label}" ]]; then
                 dotunkw_test="${unk_csv}"
                 lb_test="${lb}"
              elif [[ "${name_}" == "${tag_}" && "${lb}" == "${encoding_reference}_${label}" ]]; then
                   dotunkw_ref="${unk_csv}"
                   lb_ref="${lb}"
              fi
        done
       
    fi
}

function get_parameters
{
    tail -n +1 "${dotunkn_csv}" | read -r line; split_line "${line}" arg_s  #;echo "${arg_s[@]}"
    tail -n +2 "${dotunkn_csv}" | 
    while IFS=',' read -r "${arg_s[@]}"; do
          if [[ "${tag}" == "${tag_}" ]]; then
              check_double
          fi
    done
    #echo "${dotunkw_test},${dotunkw_ref},${lb_test},${lb_ref}"
    
}

shopt -s lastpipe
get_parameters






