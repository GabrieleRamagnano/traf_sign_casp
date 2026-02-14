#!/bin/bash
bash ./compare.sh heurate- OPT_heurate
echo "--------------------------------------------"
bash ./compare.sh heuphase OPT_heuphase
echo "--------------------------------------------"
bash ./compare.sh bddhphse BND_dhphase
echo "--------------------------------------------"
bash ./compare.sh longrate BND_longrate
echo "--------------------------------------------"
bash ./compare.sh bdheuphs NotOpt_heuphase_bound
echo "--------------------------------------------"
bash ./compare.sh bdphlngr BND_phlongr
echo "--------------------------------------------"
bash ./compare.sh opdhphse OPT_dhphase 
