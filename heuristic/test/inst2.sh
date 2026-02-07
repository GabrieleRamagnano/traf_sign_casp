#!/bin/bash

##File to organize input 
## -- the standard setting does not provide unbounded test (Task2) --

#input parameters
declare help=$* # -h option about the script

#varaiable parameters
declare -a -g horizon_s
declare -a -g time_slot_s
declare -a -g day_s
declare -a -g instance_s
declare -g muse
declare -g args

declare -a prefix_s=("inst"
                     "aux")
declare clingo_run="./${prefix_s[0]}0.sh"
declare test_run=""
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

function set_instancev2
{
    case $1 in -round) export instance="Instancesv2_round/";;
                    *) export instance="Instancesv2/";;
    esac
}

function set_bound
{
    set_instancev2 $1
    export bounds="../../Results_experiments/Task1/bounds.csv"
}

function set_standard_traffic
{
    set_bound $1
    export instance_fixed=" ./model/instance_fixed.lp "
    export enc_clingcon=" ./model/enc_clingcon.lp " 

    #compose
    args="${args}${instance_fixed}${enc_clingcon}"
    
}

function set_constants
{ 
    export const_h=" --const horizon="
    export const_b=" --const bound="
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
    instance_s=("p01" "p02" "p03" "p04" "p05")
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
    echo -e "\r${horizon_s[@]:+horizon::}""${horizon_s[@]:-horizon-empty}"
    echo -e "\r${time_slot_s[@]:+time::}""${time_slot_s[@]:-time-empty}"
    echo -e "\r${day_s[@]:+day::}""${day_s[@]:-day-empty}"    
    echo -e "\r${muse:+muse::}""${muse:-muse-empty}"
    echo -e "\r${instance_s[@]:+instance::}""${instance_s[@]:-instance-empty}"
}

function set_parameters
{
    resume
    select opt in "horizon" "time" "day" "muse" "instance" "done"; do
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
                            instance) instance_s=()
                                      insert "${opt}" instance_s inst_s
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
    local -a inst_s=("p01" "p02" "p03" "p04" "p05")
    set_parameters

}

function prepare_parameters { export args 
}

function check_muse { if [[ "${day}" == "" ]]; then return 1; fi; }

function run_experiment
{
    for inst in "${instance_s[@]}"; do
        export key="${inst}"
        for horz in "${horizon_s[@]}"; do
            export horizon="${horz}"
            export day="${muse}"
            check_muse && bash "${clingo_run}" execute
            for day in "${day_s[@]}"; do
                for time in "${time_slot_s[@]}"; do
                    export day="${day}"
                    export time_slot="${time}"
                    bash "${clingo_run}" execute
                done
            done
        done
    done   
}

function expand_cmd { echo "description not available"; }

function check_duplicate
{   
    local item=$1
    local -n ref_=$2
    local msg=$3

    if check_item "${item}" ref_ ; then 
       echo -n -e "\r${msg:+$msg}"
       return 1
    else 
       return 0 
    fi

}

function store_file
{   
    local _file=$1
    local -i idx=$2
    add choice_s "${_file}"
    add exp_choice_s "${exp_para_s[$idx]%%".lp"}"
}

function split_line
{
    local line=$1 
    local -n _input_s=$2 
    local -i start=0
    local -i holder=0
    local -i idx
    local ifs=" "
    
    line="${line}stop" 
    until [[ "${line:$holder:4}" == "stop" ]]; do 
          if [[ "${line:$holder:1}" == *"${ifs}"* && $holder -gt $start ]]; then 
             end=$(($holder - $start)) 
             add _input_s "${line:$start:$end}"
             start=$(($holder+1))  
          fi 
          ((holder++))
    done
    end=$(($holder - $start)) 
    add _input_s "${line:$start:$end}"
}

function _labels
{
    local -i len
    len="${#key}"
    if [[ "${line}" == "${key}"* ]]; then
        add label_s "${line:len}"
    fi  
}

function _files 
{
    if [[ "${line}" == *"${key}" ]]; then
        split_line "${line%"--"*}" exp_list
    fi      
}

function recover_
{    
    local item=$1
    local key=$2

    tail -n +1 "${exp_files}" | 
    while read -r line; do $item; done
}


function find
{
    local item=$1
    local -n _i=$2 

    _i=0
    for v_exp in "${exp_para_s[@]}"; do
        if [[ "${item}" == *"${v_exp}" ]]; then
            return 0
        fi
        ((++_i))
    done

}

function load_files
{
    local -i idx_
    for expf in "${exp_list[@]}"; do
        find "${expf}" idx_
        store_file "${expf}" idx_
    done
}

function menu_saved_exp
{
    local exp_files=$1
    local -a label_s
    local -a exp_list
    
    recover_ "_labels" "Name"
    select lb in "${label_s[@]}" "done"; do
           case "${lb}" in ::*) choice_s=();exp_choice_s=()
                                recover_ "_files" "--${lb:2}"
                                print_elements exp_list "${lb}...\n" 
                                load_files
                                menu_saved_exp "${exp_files}";;
                          done) echo "bye";;
                             *) echo "not valid option"
                                menu_saved_exp "${exp_files}";;
           esac
           
    break;
    done
}

function choose_files
{
    local messg="file already exists\n"
    select file in "${file_s[@]}" "export_files.txt" "done"; do
           case "${file}" in *.lp) check_duplicate "${file}" choice_s "${messg}" &&
                                   store_file "${file}" "$(($REPLY-1))"
                                   choose_files;;
                             export_files.txt) menu_saved_exp "${file}"
                                               choose_files;;
                             done) echo "good choice!"
                                   echo "bye";;
                                *) echo "not valid option"
                                   choose_files;;
           esac
    break;
    done
}

function list
{
    local -n _flist=$1
    local root=$2
    local -i idx

    tree "${root}" -i $3 -v | 
    while read -r line; do
          if [[ "${line}" == *$4 ]]; then  
             add _flist "${line}"
          fi  
    done
}

function composexp 
{
    local -n arg_s=$1
    local -i idx

    args=""
    idx=0
    for elem in "${arg_s[@]}"; do
        export "${exp_choice_s[$idx]}=${elem}"
        args="$args ""${elem}"
        ((idx++))
    done
}

function print_elements
{     
    local -n arr_=$1
    local msg=$2

    echo -n -e "\r${arr_:+$msg}"
    for elem in "${arr_[@]}"; do
        echo -e "\r${elem}" 
    done 
}

function name_file_set
{
    echo -e "\rHow do you call this file set?"
    echo -e "\rName: \c"
    read -e name
    echo -e "\rThe name is: ${name}"
    echo -e "\rAre you sure of your choice[y/n]?\c"
    bash "${utility}" general_answer || name_file_set
}

function save_file_set
{
    local name

    echo -e "\rDo you want to save this file set?[y/n]\c"
    if bash "${utility}" general_answer; then
       name_file_set
       echo "Name::${name}" >> export_files.txt
       echo "${args}--${name}" >> export_files.txt
       echo -e "\rThe file set ${name} is saved!"
    fi
}

function file_set
{
    local -a file_s exp_para_s choice_s exp_choice_s

    list file_s "./model" "-f" ".lp"
    list exp_para_s "./model" " " ".lp"
    choose_files
    print_elements choice_s "The files are\n"
    print_elements exp_choice_s "The export variables are\n"
    echo -e "\rAre you sure of your choices?[y/n]\c"
    if bash "${utility}" general_answer; then 
       composexp choice_s
       save_file_set
       return 0
    else
        echo "files deleted"
        choice_s=()
        file_set
    fi 
    #echo "${choice_s[@]}"

}

function preset_options
{
    local input
    echo -e "digit -heu for the heuristic version:\c "
    read -e input
    set_options "${input}"
}

function round_choice
{
    local -n _input=$1
    echo -e "digit -round for selecting Instancesv2_round/:\c "
    read -e _input 
}

function preset_standard_traffic
{   
    local input
    round_choice input
    set_standard_traffic "${input}"
}

function preset_bound
{
    local input
    round_choice input
    set_bound "${input}"
}

function exp_view
{
    local -n _item_s=$1
    local msg=$2

    for item in "${_item_s[@]}"; do
        echo "${item}"
    done 
    echo -e "${msg}"
    bash "${utility}" general_answer || return 1
}

function additional_export
{
    local -a package_s=("standard_traffic_instance"
                        "clingo_constants"
                        "clingo_options"
                        "standard_output"
                        "traffic_parameters"
                        "set_bound")
    root="./result"
    local -a std_output_s=("${root}""/out_txt/" 
                           "${root}""/out_lp/")
    classic=" --config=crafty --time-limit=600 "
    local -a option_s=("${classic}"
                       "${classic} --heuristic=Domain ")
    local -a cost_s=("--const horizon="
                     "--const bound=")
    local -a std_traffic_s=("../../Results_experiments/Task1/bounds.csv"
                            "./model/instance_fixed.lp "
                            "./model/enc_clingcon.lp "
                            "Instancesv2_round/ | Instancesv2/")
    local -a bound_s=("../../Results_experiments/Task1/bounds.csv"
                     "Instancesv2_round/ | Instancesv2/")
    local messg="Do you want to export these variables?[y/n]\c"

    echo "There are also these additional packages:"
    select pack in "${package_s[@]}" "done"; do
           case "${pack}" in standard_traffic_instance) 
                             exp_view std_traffic_s "${messg}" &&
                             preset_standard_traffic
                             additional_export;;
                             clingo_constants) 
                             print_elements cost_s
                             exp_view const_s "${messg}" &&
                             set_constants
                             additional_export;;
                             clingo_options) 
                             exp_view option_s "${messg}" && 
                             preset_options
                             additional_export;;
                             standard_output) 
                             print_elements std_output_s
                             exp_view std_output_s "${messg}" &&
                             set_standard_output
                             additional_export;;
                             traffic_parameters) 
                             customize_data #aggiungere opzione complete_data
                             additional_export;;
                             set_bound) 
                             exp_view bound_s "${messg}" &&
                             preset_bound
                             additional_export;;
                             done) echo "bye";;
                                *) echo "not valid option"
                                   additional_export;; 

           esac
    break;
    done
}

function set_script
{
    local -a script_s 
    ls *.sh | 
    while read -r line; do add script_s "${line}"; done
    echo "Choose the script for testing your code:"
    select script in "${script_s[@]}" "done";do
           case "${script}" in done) echo "bye";;
                                  *) test_run="${script}"
                                     echo "The file choosen is ${test_run}"
                                     echo -e "Continue?[y/n]\c"
                                     bash "${utility}" general_answer || set_script
           esac
    break;
    done
}

function see_services
{
    local -a service_s=("customize_run"
                        "total_run"
                        "test_run")
    
    select srv in "${service_s[@]}" "done"; do
           case "${srv}" in customize_run) service="customize_run"
                                           see_services;;
                            total_run) service="total_run"
                                       see_services;;
                            test_run) file_set
                                      additional_export
                                      set_script
                                      service="test_run"
                                      see_services;;
                            done) echo "bye";;
                               *) echo "input not correct"
                                  see_services;;
           esac
    break;
    done 
}

function test_run
{
    #echo "not available yet..."
    prepare_parameters 
    clingo_run="${test_run}"
    bash "${clingo_run}" move
    run_experiment
    bash "${clingo_run}" delete

}

function total_run
{
    set_task
    complete_data
    prepare_parameters
    run_experiment
}

function customize_run
{
    set_task
    customize_data
    prepare_parameters
    run_experiment
}

function execute
{
    local svr=$1
    case "${svr}" in customize_run) customize_run;;
                     total_run) total_run;;
                     test_run) test_run;;
                     *) echo "error";;
    esac
}

function collect_exp
{
    local -n _exp_s=$1
    export -p | 
    while read -r line; do
          add _exp_s "${line}" 
    done
}

function data_loaded
{
    local -a final_export_s

    collect_exp final_export_s
    for new_exp in "${final_export_s[@]}"; do
        if check_duplicate "${new_exp}" init_export_s; then
           echo -e "\r${new_exp:11}"
        fi
    done 
    resume

}

function fast_run
{
    local -a input_s
    local -a init_export_s
    local service

    #echo "bash filename [prefix] [suffix] [-f foldername]"
    #echo -e "bash ./create_scripts.sh\c"
    collect_exp init_export_s
    see_services
    #run program
    execute "${service}"
    data_loaded

}

function menu
{   
    select opt in "${options[@]}"; do
           case $opt in continue...) expand_cmd 
                                     menu;;
                        run) fast_run;;
                        exit) echo "bye";;
                        *) echo "non valid option!"
                           menu;;
           esac
    break;
    done
}

function show_cmd
{
    local -a options=("continue..."
                      "run"
                      "exit")

    echo "bash filename -h"
    menu    
}

function prompt
{
    local -a input

    case "${help}" in -h) show_cmd;;
                       *) echo "not available to be run independently";;
    esac 
}

shopt -s lastpipe
prompt
