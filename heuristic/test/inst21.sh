#!/bin/bash

clingcon ../hull/fixed-test-5/p01[count=350].lp \
         ./model/instance_fixed_hull.lp \
         ./model/constants.lp \
         ./model/enc_conf.lp \
         ./model/enc_counter.lp
         #./model/enc_clingcon.lp \
         #--config=crafty --time-limit=600 --q=1 \
         #--const horizon=600 --const bound=0