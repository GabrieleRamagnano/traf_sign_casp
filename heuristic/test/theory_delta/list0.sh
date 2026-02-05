#!/bin/bash

tree -i -f | while read -r line; do if [[ "${line}" == *"l1"* ]]; then echo $line; fi; done
