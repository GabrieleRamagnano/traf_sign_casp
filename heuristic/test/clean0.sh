#!/bin/bash

declare pkg="./packgs0.csv"
declare utility="./aux0.sh"

function clean_tails
{
    tail -n +2 "${pkg}" | 
    while IFS=',' read -r name package label _tail _runtl ; do
          bash "${utility}" search ".,${_tail:2}" && rm -r "${_tail}"
          bash "${utility}" search ".,${_runtl:2}" && rm -r "${_runtl}"
    done
}

shopt -s lastpipe
"$@"