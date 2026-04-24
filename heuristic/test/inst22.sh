#!/bin/bash

clingcon ../hull/fixed-test-5/p01[count=350].lp \
         ./model/instance_fixed_hull.lp \
         ./model/constants.lp \
         ./model/enc_conf.lp \
         ./model/enc_counter2.lp \
         --config=crafty --time-limit=600 --q=1 \
         --const horizon=600 --const bound=0
         #./model/enc_clingcon_not_opt.lp \
         #--config=crafty --time-limit=600 --q=1 \
         #--const horizon=600 --const bound=0
