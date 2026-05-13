#!/bin/bash

declare pkg="./packgs0.csv"
declare inst="./inst13.sh"

tail -n +2 "${pkg}" | while IFS=',' read -r name package label _tail _runtl ;do
    if [[ "${name}" == "CAFE_DHXplink" ]]; then
	echo "${name}"
	  { export tag="${name}" 
	    bash "${inst}" move
	    bash "${inst}" print
        bash "${inst}" delete; } &
	fi
done


tail -n +2 "${pkg}" | while IFS=',' read -r name package label _tail _runtl ;do
    if [[ "${name}" == "PDDL_DHXplinkmin" ]]; then
       echo "${name}"
	  { export tag="${name}" 
	    bash "${inst}" move
	    bash "${inst}" print 
        bash "${inst}" delete; } & 
	fi
done

