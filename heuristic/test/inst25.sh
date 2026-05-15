#!/bin/bash

declare pkg="./packgs0.csv"
declare -a arr_=("name"
                 "package"
                 "label"
                 "_tail"
                 "_runtl")

tail -n +2 "${pkg}" | while IFS=',' read -r "${arr_[@]}" ;do
    if [[ "${name}" == "PDDL_TEST70" ]]; then
       echo "${name}" 
	fi
    if [[ "${package}" == "pddl_105" ]]; then
       echo "${package}" 
	fi
done