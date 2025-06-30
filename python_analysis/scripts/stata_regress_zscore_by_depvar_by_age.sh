#!/bin/bash

parse_logs ()
{
  infile=$1
#  summary_list=$(egrep "^z_|Number of obs|Adj R-squared|^               total_iq_8" ${infile} | sed -e 's/^.*Number/Number/g' -e 's/^.*Adj/Adj/g' -e 's/\|//g' | dos2unix | paste -d' ' - - - -)
  summary_list=$(egrep "^z_|Number of obs|Adj R-squared|^             z_total_iq_8" ${infile} | egrep -v "^z_total_iq_8|^z_IQ" | sed -e 's/^.*Number/Number/g' -e 's/^.*Adj/Adj/g' -e 's/\|//g' | dos2unix | paste -d' ' - - - -)

  echo " DepVar        Coefficient(95% CI)        P-value      R2        Num-of-obs  Missed-Values"
  echo "---------  ---------------------------    -------    ------      ----------  ------------"
  echo "${summary_list}" | while read i
  do
    z_var_age=$(echo $i | awk '{print $1}')
    var=$(echo $i | awk '{print $1}' | awk -F'_' '{print $2}')
    age=$(echo $i | awk '{print $1}' | awk -F'_' '{print $3}')
    coef=$(echo ${i} | awk '{print $17}')
    lci=$(echo ${i} | awk '{print $21}')
    uci=$(echo ${i} | awk '{print $22}')
    pval=$(echo ${i} | awk '{print $20}')
    adj_r2=$(echo ${i} | awk '{print $15}')
    obs=$(echo ${i} | awk '{print $11}')
    miss=$(echo ${i} | awk '{print $4}')

    form_coef=$(printf '%.4f' "$coef")
    form_lci=$(printf '%.4f' "$lci")
    form_uci=$(printf '%.4f' "$uci")
    form_pval=$(printf '%.4f' "$pval")
    form_adj_r2=$(printf '%.4f' "$adj_r2")
    form_miss=$(printf "%'3d" $miss)

    form_ci=$(printf "%s(%s to %s)" $form_coef $form_lci $form_uci)
    printf "%-10s %-30s %-10s %-10s %8s %12s\n" "$z_var_age" "$form_ci" "$form_pval" "$form_adj_r2" "$obs" "$form_miss"
  done
}

# list of all the log files that will be parsed
log_list="js_cfpwv_bmi.log js_cfpwv_wc.log js_cfpwv_bp_sys.log js_cfpwv_bp_dia.log js_cfpwv_chol.log js_cfpwv_hdl.log js_cfpwv_ldl.log js_cfpwv_trig.log js_cfpwv_glc_meta.log js_cfpwv_insul.log js_cfpwv_cfpwv.log"

log_dir="../../stata/log_files"

parse_logs_tmp="parse_logs.tmp"
rm -f ${parse_logs_tmp}

for i in ${log_list}
do
  # echo "[log file = [$i]"
  parse_logs "${log_dir}/$i"  >> ${parse_logs_tmp}
done

# now, fill in the gap that does NOT have any data
for i in bmi wc bp_sys bp_dia chol hdl ldl trig glc_meta insul cfpwv
do
  echo "DepVar: [$i]"
  echo "DepVar,Coefficient(95% CI),P-value,R2,Num-of-obs,Missing-Values"
  #for j in 9 10 11 12 13 15 17 24
  for j in 9 17 24
  do
    check=$(grep z_${i}_${j} ${parse_logs_tmp})
    if [ "x${check}" = "x" ]
    then
      echo "z_${i}_${j},NO_DATA,NO_DATA,NO_DATA,NO_DATA,NO_DATA"
    else
      # z_bmi_11 -0.0034(-0.0051 to -0.0018) 0.0000 0.0154 5,374 8,551
      echo ${check} | sed -e 's/ to /_to_/g' -e 's/\,//g' -e 's/ /,/g' -e 's/_to_/ to /g'
    fi
  done
  echo
done

rm -f ${parse_logs_tmp}
