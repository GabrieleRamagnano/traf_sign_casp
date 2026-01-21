#!/bin/bash

##File to organize input 
## -- the standard setting does not provide unbounded test (Task2) --

#varaiable parameters
declare -a -g horizon_s
declare -a -g time_slot_s
declare -a -g day_s
declare -g muse
declare -g args

declare -a prefix_s=("inst"
                     "aux")
declare clingo_run="./${prefix_s[0]}0.sh"
declare utility="./${prefix_s[1]}0.sh"

function set_test_traffic
{
    export phase_limit=" ./model/data/phase_limit.lp "
    export turnrate=" ./model/data/turnrate.lp "
    export capacity=" ./model/data/capacity.lp "
    export occupancy=" ./model/data/init_occ.lp "
    export activation=" ./model/data/activation.lp "
    export instance_fixed=" ./model/instance_fixed.lp "
    export constants=" ./model/constants.lp "
    export configuration=" ./model/enc_conf.lp "
    export counter=" ./model/enc_counter.lp " 

    #compose
    args="${phase_limit}${turnrate}${capacity}${occupancy}${activation}"
    args="${args}${instance_fixed}${constants}${configuration}${counter}"
}

function set_standard_traffic
{
    case $1 in -round) export instance="Instancesv2_round/";;
                    *) export instance="Instancesv2/";;
    esac
    export bounds="../../Results_experiments/Task1/bounds.csv"
}

function set_constants
{ 
    const_h=" --const horizon="
    const_b=" --const bound="

    #compose
    args="${args}${const_h}${const_b}"
}

function set_options
{
    local classic=" --config=crafty --time-limit=600 "
    local opt_heu=" --heuristic=Domain "
    
    case $1 in -heu) export options="${classic}${opt_heu}";;
                  *) export options="${classic}";;
    esac  

    #compose
    args="${args}${options}"
}

function set_standard_output
{
    export root="./result"
    export dir_txt="${root}""/out_txt/"
    export dir_lp="${root}""/out_lp/"
}

function set_task
{
    local round=$1
    local heuristic=$2

    set_standard_traffic "${round}"
    set_constants
    set_options "${heuristic}"
    set_standard_output
}

function complete_data
{
    horizon_s=("600" "660" "720" "780" "840" "900")
    time_slot_s=("morn" "noon" "eve")
    day_s=("26" "30")
    muse="muse"
}


function add
{
    local -n lst=$1
    local -i idx

    idx="${#lst[@]}"
    lst[idx]+="${input}"
    echo "${lst[@]}"
}

function check_input
{
    local -n lst=$1

    #first check list
    for l in "${lst[@]}"; do
        if [[ "$l" == "${input}" ]];then
            echo "this input exists!"
            return 1
        fi
    done
    #then check horizon
    for h in "${horz_s[@]}"; do
        if [[ "$h" == "${input}" ]];then
            return 0
        fi
    done
    return 1
}

function insert
{
    local -n list_=$1

    echo "horizon: ""${horz_s[@]}"
    echo -e "choose::\c"
    read -e input
    check_input list_ && echo "valid input!" && add list_ ||
    (echo "input not valid")
}

function addi
{
    local in_=$1
    local -n lst=$2
    local -i idx

    idx="${#lst[@]}"
    lst[idx]+="${in_}"
    echo "${lst[@]}"
}

function has_item
{
    local item=$1
    local -n out=$2
    for elem in "${out[@]}"; do
        if [[ "${elem}" == "${item}" ]]; then
            return 1
        fi
    done
    return 0
}

function change
{
    local -n swap_s=$1
    local -n _output=$2
 
    #echo "ciao"
    for sw in "${swap_s[@]}"; do
        has_item "${sw}" _output &&
        addi "${sw}" _output
    done

}

declare -a -g output
function menu
{
    local -n _list=$1
    #local -a output


    echo "${_list[@]}"
    select opt in "horizon" "time" "day" "done"; do
           case "${opt}" in horizon | time | day) insert _list #"${opt}"
                                                  echo "${_list[@]}"
                                                  change _list output
                                                  echo "${output[@]}"
                                                  menu output;;
                            done) echo "bye";;
                            *) echo "not valid option"
                               change _list output
                               menu output;;
           esac

    break;
    done
}

function customize_data
{

    local -a horz_s=("600" "660" "720" "780" "840" "900")
    local -a time_s=("morn" "noon" "eve")
    local -a days=("26" "30")
    local ms="muse"
    local input
    local -a list

    menu list
}

function prepare_parameters { export args 
}

function run_experiment
{
    for horz in "${horizon_s[@]}"; do
        export horizon_s="${horz}"
        export day="${muse}"
        bash "${clingo_run}"
        for day in "${day_s[@]}"; do
            for time in "${time_slot_s[@]}"; do
                export day="${day}"
                export time_slot="${time}"
                bash "${clingo_run}"
            done
        done
    done   
}

shopt -s lastpipe
customize_data
