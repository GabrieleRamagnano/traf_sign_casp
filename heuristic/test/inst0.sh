#!/bin/bash

#variable parameters
export args
declare -a argument_s
declare scenario="${day}${time_slot}"

declare prefix="aux"
declare utility="./${prefix}0.sh"

function split
{
    local origin=$1 k=$2
    local -n _root=$3 _tail=$4
    _root="${origin%%"$k"*}"
    local -i len="${#_root}"
    _tail="${origin:len}"
}

function run_test
{
    local root tail
   
    tail -n +2 $bounds | while IFS=',' read -r HORIZON PROBLEM MIN; do
        if [[ "$PROBLEM" == *"$instance"*"$scenario"*"$key"* ]]; then
            if [[ "$HORIZON" == "$horizon" ]]; then 
                echo $HORIZON $PROBLEM
                asp_instance="../../${PROBLEM}.lp"
                out_lp="${dir_lp}${PROBLEM}.lp"
                split "${out_lp}" "${key}" root tail 
                clingcon $asp_instance \
                         $args \
                         $const_h$HORIZON \
                         $const_b$MIN \
                         > "${dir_txt}${PROBLEM}.txt" 2>/dev/null
                tail -n +1 < "${dir_txt}${PROBLEM}.txt" |
                bash "${utility}" "reorder_result" "${root}","${tail}"
            fi
        fi
    done
}


function execute
{
    run_test 
    #echo $( export -p)
    echo $args
    
}

shopt -s lastpipe
execute

