#!/bin/bash

#variable parameters
export args
declare -a argument_s
declare scenario="${day}${time_slot}"

declare prefix="aux"
declare utility="./${prefix}0.sh"

function run_test
{
    local key=$1

    tail -n +2 $bounds | while IFS=',' read -r HORIZON PROBLEM MIN; do
        if [[ "$PROBLEM" == *"$instance"*"$scenario"*"$key"* ]]; then
            if [[ "$HORIZON" == "$horizon" ]]; then 
                echo $HORIZON $PROBLEM
                asp_instance="../../${PROBLEM}.lp"
                clingcon $asp_instance \
                         $args \
                         $const_h$HORIZON \
                         $const_b$MIN \
                         > "${dir_txt}${PROBLEM}.lp" 2>/dev/null
                tail -n +1 < "${dir_txt}${PROBLEM}.lp" |
                bash "${utility}" "reorder_result" "${dir_lp}${PROBLEM}.lp"
            fi
        fi
    done
}


function execute
{
    run_test p01
}

shopt -s lastpipe
execute

