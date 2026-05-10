#!/bin/bash 

#input parameters
declare name1=$1
declare name2=$2
declare lb1=$3
declare lb2=$4
declare label_ref=$3

#variable parameters

## -- python utilities -- ##
declare -g py_dot="  ./inst0.py "   # dot-convertitor
declare -g py_aggr=" ./inst1.py "   # results aggregator
declare -g py_plot="./inst7.py"     # plotter

## -- csv files -- ##
declare -g csv_host1     # host: experiment
declare -g csv_host2     # host: experiment
declare -g csv_host_dot1 # dot-host: after dot-conversion
declare -g csv_host_dot2 # dot-host: after dot-conversion

declare -g csv_ref      # reference: to compare with experiment
declare -g csv_ref_dot  # dot-reference: after dot-conversion

# aggregate over horizons
declare horizon_s=("600" "660" "720" "780" "840" "900")
declare -g data_plot="./results.txt" # data for the plotter
declare -g data_plot_inst="./results_inst.txt" # data for the plotter



function plot
{
    python3 "${py_plot}" "${data_plot}" $name1 $name2 target "${lb1}" "${lb2}"
}


plot







