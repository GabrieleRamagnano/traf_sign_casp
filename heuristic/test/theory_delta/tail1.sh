#!/bin/bash

#variable parameters
declare scenario="${day}${time_slot}"

function run_test
{   
    tail -n +2 "$bounds" | while IFS=',' read -r HORIZON PROBLEM MIN; do
        if [[ "$PROBLEM" == *"$instance"*"$scenario"*"$key"* ]]; then
            if [[ "$HORIZON" == "$horizon" ]]; then 
                echo $HORIZON $PROBLEM
                asp_instance="../../${PROBLEM}.lp"
                clingcon $asp_instance \
                         $args \
                         $const_h$HORIZON \
                         $const_b$MIN \
                         > "${dir}${PROBLEM}.txt" 2>/dev/null
            fi
        fi
    done
}


function execute
{
    run_test     
}

shopt -s lastpipe
execute