#!/bin/bash
rm -r results.txt
echo "--------------------------------------------"
bash ./compare.sh heurate- OPT_heurate "900" 
echo "--------------------------------------------"
bash ./compare.sh heuphase OPT_heuphase "900" 
echo "--------------------------------------------"
bash ./compare.sh bddhphse BND_dhphase 
echo "--------------------------------------------"
bash ./compare.sh longrate BND_longrate 
echo "--------------------------------------------"
bash ./compare.sh bdheuphs NotOpt_heuphase_bound 
echo "--------------------------------------------"
bash ./compare.sh bdphlngr BND_phlongr 
echo "--------------------------------------------"
bash ./compare.sh opdhphse OPT_dhphase "900" 
echo "--------------------------------------------"
#bash ./compare2.sh fire "" ""
