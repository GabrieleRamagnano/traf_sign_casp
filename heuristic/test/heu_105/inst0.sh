#!/bin/bash
rm -r results.txt
echo "--------------------------------------------"
bash ./compare.sh opdhphse OPT_dhphase OPT_clingcon "900" 
echo "--------------------------------------------"
bash ./compare.sh opdhctrphs OPT_dhctrphs OPT_clingcon "900"
echo "--------------------------------------------"
bash ./compare.sh opdhextphs OPT_dhextphs OPT_clingcon "900"  
echo "--------------------------------------------"
bash ./compare.sh opdhctrphs OPT_dhctrphs OPT_dhphase "900"
echo "--------------------------------------------"
bash ./compare.sh opdhextphs OPT_dhextphs OPT_dhphase "900" "ok"
echo "--------------------------------------------"
