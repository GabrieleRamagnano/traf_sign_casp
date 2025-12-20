#!/bin/bash

declare -a asp_outputs 
declare -a answ_sets
declare -a path


asp_outputs=()
answ_sets=()
path=("wrac1,y,wrbc1" 
      "wrbc1,b,wrcc1" 
      "wrcc1,x,wrdc1" 
      "wrdc1,b,wrec1" 
      "wrec1,y,wrfc1")
fst_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total"


horizon=$1
day=$2
time_slot=$3
scenario="${day}${time_slot}"


instance_round="Instancesv2_round/"
instance="Instancesv2/"
bounds="../Results_experiments/Task1/bounds.csv" 
csv="./results_hcafe/result_det_bound_hcafe_${horizon}_${scenario}.csv"


function set_csv { ls $csv && rm -r $csv; printf "$fst_line"$'\n' > $csv 
}

function print_elements
{     
    local -n arr_=$1

    echo "The result is "
    for elem in "${arr_[@]}"; do
        echo $elem 
    done 
}

function select_instances
{
    local -n _asp_outputs=$1

    tail -n +2 $bounds | while IFS=',' read -r HORIZON PROBLEM MIN; do
        if [[ "$PROBLEM" == *"$instance"*"$scenario"* ]]; then
           if [[ "$HORIZON" == "$horizon" ]]; then  
              idx=${#_asp_outputs[@]}
              asp_output="${PROBLEM}_asp_bound_hcafe_$HORIZON.txt"
              _asp_outputs[idx]=$asp_output                 
           fi 
        fi
    done  
    #print_elements _asp_outputs 
}

function calculate_position
{
    local -n word=$1 _line=$2 _len=$3 _start=$4 _end=$5

    #calculate word's length
    _len=${#word}
    #calculate the starting and ending poisition of the word in line
    _start=0
    until [[ "$word" == "${_line:$_start:$_len}" ]]; do ((_start++)); done
    _end=$(($_start + $_len))   #; echo $_end
}

function calc_atom_value
{   
    local -n _atom_value=$1 _end=$2 _line=$3 
    local digit
    
    #start consifering the first digit of the atom
    digit="${_line:$_end:1}"
    _atom_value=""
    until [[ $(case $digit in 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9) echo -n $digit;;
                              *) echo -n "end";;
               esac) == "end" ]]; do 
        _atom_value=$_atom_value$digit
        ((_end++))
        digit="${_line:$_end:1}" #;echo $_atom_value
    done
}

function find_counter
{
    local -i len start end 
    local -n line_=$1 
    local counter_value

    for link in "${path[@]}"; do 
        if [[ "$line_" == *"counter(${horizon},link(${link}))="* ]]; then    
          counter="counter(${horizon},link(${link}))="
          calculate_position counter line_ len start end
          calc_atom_value counter_value end line_ 
          answ_sets[-1]+=";${line_:$start:$len}${counter_value[@]}"
          #echo "${line_:$start:$len}${counter_value[@]}"
        fi
    done
     
}

function calc_answ_number { calc_atom_value $1 $2 $3
}

function find_answ_sets
{   
    local -i len start end 
    local -n _asp_output=$1 line_=$2 
    local n_answer

    if [[ "$line_" == *"Answer: "* ]]; then
      answer="Answer: "
      calculate_position answer line_ len start end
      calc_answ_number n_answer end line_
       
      idx="${#answ_sets[@]}"
      answ_sets[idx]=$_asp_output"::"${line_:$start:$len}${n_answer[@]}
      #echo "${line_:$start:$len}${n_answer[@]}"
      #print_elements answ_sets
    fi
}

function read_instances
{ 
   for asp_out in "${asp_outputs[@]}"; do
      #echo $asp_out":: opened "
      tail -n +2 $asp_out | while read -r line; do 
          find_answ_sets asp_out line
          find_counter line      
      done
   done 
   #echo $asp_out":: closed "
}

function get_num_link
{
    local word=$1
    local -n _link_n=$2
    local -i n=0

    for link in "${path[@]}"; do
        if [[ "$word" == *"$link"* ]]; then
            _link_n=$n; else
            ((n++))
        fi
    done #; echo $word "number:"$_link_n

}


function go_ahaed
{
    local -n _key=$1 _prefix=$2 _elem=$3 link_n_=$4
    local -i start  

    start=${#_prefix}
    until [[ "$_key" == "${_elem:$start:1}" ]]; do ((start++)) done
    get_num_link "${_elem:${#_prefix}:$(($start - ${#_prefix}))}" link_n_ 

    ((start++))
    _prefix="${_elem:0:$start}"
}

function calculate_tot_counter
{
    local key="="
    local prefix
    local counter_value
    local -i end tot_value link_n
    local -a counter_s 
    
    #echo "------------------------------------------------------------------"
    for asp_out in "${asp_outputs[@]}"; do
        #find for all the asp_outputs only the results of the 'Answer: 1'
        prefix="${asp_out}::Answer: 1"
        for elem in "${answ_sets[@]}"; do
            #get the value of each counter atom in the answer set 1
            tot_value=0 
            end=${#prefix}
            counter_s=(, , , , ,)
            last=${#counter_s[*]}
            if [[ "$elem" == "$prefix"* ]]; then
               while [[ "${elem:$end:1}" == ";" ]]; do
                     go_ahaed key prefix elem link_n
                     end=${#prefix}                         #; echo $prefix
                     calc_atom_value counter_value end elem
                     #sum all the counter's values 
                     tot_value+=$counter_value              #; echo $tot_value
                     #add values to printout
                     counter_s[$link_n]+=$counter_value     #; echo ${counter_s[*]}
                     counter_s[last]=","$tot_value          #; echo ${counter_s[*]}
               done; printf "clingcon,${horizon},${asp_out}${counter_s[*]}"$'\n' >> $csv
            fi
        done
    done

}

shopt -s lastpipe
set_csv
select_instances asp_outputs
read_instances
calculate_tot_counter

