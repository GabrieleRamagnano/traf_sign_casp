#!/bin/bash

### Directory management

declare -a path1_s path2_s
declare -a time_slot_s
declare -a day_s

declare utility="./aux0.sh"

function set_root {
    root="./$1/result"
}

function set_paths
{
    set_root $1
    dir1="/Instancesv2/sippv2/fixlen4"
    dir2="/Instancesv2_round/sippv2/fixlen4"

    path1_s=("$root"
             "/Instancesv2"
             "/sippv2"
             "/fixlen4")
    path2_s=("$root"
             "/Instancesv2_round"
             "/sippv2"
             "/fixlen4")

    time_slot_s=("morn" 
                 "noon" 
                 "eve")
    day_s=("26" 
           "30")

    muse="/muse"
}

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

function check_folder {   

    search "." $1 || mkdir $1
}

function create_folders
{
    local path1="" 
    local path2=""

    set_paths $1
    for dir in "${path1_s[@]}"; do path1="$path1""$dir"; check_folder $path1; done
    for dir in "${path2_s[@]}"; do path2="$path2""$dir"; check_folder $path2; done

    for scenario in {/26,/30}{morn,noon,eve}; do
        check_folder "$path1""$scenario"
        check_folder "$path2""$scenario"       
    done

    #muse
    check_folder "$path1""$muse"
    check_folder "$path2""$muse"
}

function delete_folders
{
    set_root $1
    rm -r "${root}"
}

function file_cleaning
{
    set_root $1
    tree "${root}" -i -f | 
    while read -r line; do 
      if [[ "${line}" == *".sh" ]]; then
         rm -r "${line}"
      fi
    done

}


#create_folders main_folder
#delete_folders main_folder
#files_cleaning main_folder
shopt -s lastpipe
"$@"

