#!/bin/bash

echo "iq,depvar,age,beta,lci,uci"

log_list="js_cfpwv_bmi.log js_cfpwv_wc.log js_cfpwv_bp_sys.log js_cfpwv_bp_dia.log js_cfpwv_chol.log js_cfpwv_hdl.log js_cfpwv_ldl.log js_cfpwv_trig.log js_cfpwv_glc_meta.log js_cfpwv_insul.log js_cfpwv_cfpwv.log"
log_dir="../log_files"

for i in ${log_list}
do
  grep "Regression results summary" "${log_dir}/$i" | awk '{print $5","$8","$11","$14","$17","$20}' | dos2unix
done
