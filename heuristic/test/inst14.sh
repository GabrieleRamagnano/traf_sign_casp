#!/bin/bash

declare pkg="./packgs0.csv"
declare inst="./inst13.sh"

tail -n +2 "${pkg}" | while IFS=',' read -r name package label _tail _runtl ;do
	{ export tag="${name}" 
	  bash "${inst}" print 
          bash "${inst}" delete; } & 
done



