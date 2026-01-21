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
    local -n _arr=$1
    local -i idx

    idx="${#_arr[@]}"
    _arr[idx]+=$2  #;echo "${_arr[@]}"
}

function check_item
{
    local item=$1
    local -n _ref=$2

    for elem in "${_ref[@]}"; do
        if [[ "${elem}" == "${item}" ]]; then
            return 0
        fi
    done
    return 1
}

function check_input
{   
    local -n _lst=$1 _reference=$2
    local -a tmp_s
    
    #check the correctness of the input
    for elem in "${input_s[@]}";do
        check_item "${elem}" _reference && 
        add tmp_s "${elem}" || return 1
    done
    #set the main list with the current input
    for t in "${tmp_s[@]}"; do
        add _lst "${t}"
    done
    return 0
}

function insert
{
    local type=$1
    local -n _list=$2 _choice_s=$3
    local -a input_s

    echo "${type}: ""${_choice_s[@]}"
    echo -e "choose::\c"
    #read input
    read -e -a input_s
    #validation input
    check_input _list _choice_s ||
    (echo "input not valid")
}

function set_var
{
    local -n _var=$1
    local name=$2
    local input

    echo "${_var:-$name}"
    echo -e "choose::[y/n]\c"
    #read input
    read -e input
    #validate input
    case "${input}" in y) _var="muse";;
                       n) echo "${_var:-$name not set}";;
                       *) echo "input not valid";;
    esac 
}

function resume 
{
    echo "current setting:"
    echo "${horizon_s[@]:+horizon::}" \
         "${horizon_s[@]:- horizon-empty}"
    echo "${time_slot_s[@]:+time::}" \
         "${time_slot_s[@]:- time-empty}"
    echo "${day_s[@]:+day::}" \
         "${day_s[@]:- day-empty}"    
    echo "${muse:+muse::}"\
         "${muse:-muse-empty}"
}

function set_parameters
{
    resume
    select opt in "horizon" "time" "day" "muse" "done"; do
           case "${opt}" in horizon) horizon_s=()
                                     insert "${opt}" horizon_s horz_s
                                     set_parameters;;
                            time) time_slot_s=()
                                  insert "${opt}" time_slot_s time_s
                                  set_parameters;;
                            day) day_s=()
                                 insert "${opt}" day_s days
                                 set_parameters;;
                            muse) muse=""
                                  set_var muse "muse"
                                  set_parameters;; 
                            done) echo "bye";;
                            *) echo "not valid option"
                               set_parameters;;
           esac

    break;
    done

    ###todo...in future
    #bash "${utility}" set_var muse,"muse"
    #tail -n +1 tmp.txt | read -r line; muse="${line}"
}

function customize_data
{

    local -a horz_s=("600" "660" "720" "780" "840" "900")
    local -a time_s=("morn" "noon" "eve")
    local -a days=("26" "30")
    local ms="muse"
    set_parameters

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
