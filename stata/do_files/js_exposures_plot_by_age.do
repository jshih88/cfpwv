** Standard settings **
version 18.5
clear all
macro drop _all
set more off
set maxvar 10000
// CHANGEME !! //
sysdir set PLUS "S:\ICS_Student_Projects\2024-25\Jocelyn"

** Set Directory **
// CHANGEME !! //
cd "S:\ICS_Student_Projects\2024-25\Jocelyn"

** Import Data **
import delimited "tables\js_cfpwv.csv", clear
label var beta "Beta Coefficient"

** Clean up depvar names for legend and labels **
gen depvar_clean = subinstr(subinstr(depvar, "_", " ", .), "(", "", .)
replace depvar_clean = subinstr(depvar_clean, ")", "", .)

** Assign Custom ID Order **
gen id = .
replace id = 1  if depvar == "BMI_(bmi)"
replace id = 2  if depvar == "Waist_circumference_(wc)"
replace id = 3  if depvar == "Systolic_blood_pressure_(bp_sys)"
replace id = 4  if depvar == "Diastolic_blood_pressure_(bp_dia)"
replace id = 5  if depvar == "Cholesterol_(chol)"
replace id = 6  if depvar == "High-density_lipoprotein_(HLD)_(hdl)"
replace id = 7  if depvar == "Low-density_lipoprotein_(LDL)_(ldl)"
replace id = 8  if depvar == "Triglycerides_(trig)"
replace id = 9  if depvar == "Glucose_metabolism_(glc_meta)"
replace id = 10 if depvar == "Insulin_(insul)"
replace id = 11 if depvar == "Carotid_femoral_pwv_(cfpwv)"

** Define labels for the custom order **
label define depvar_order 1 "BMI" 2 "Waist Circumference" 3 "Systolic BP" 4 "Diastolic BP" ///
    5 "Cholesterol" 6 "HDL" 7 "LDL" 8 "Triglycerides" 9 "Glucose Metabolism" 10 "Insulin" 11 "Carotid Femoral PWV"
label values id depvar_order

** Get unique ages **
levelsof age, local(age_list)

** Loop over each age **
foreach vage of local age_list {
    preserve

    ** Filter data for the current age **
    keep if age == `vage'

    ** Count number of depvars for this age (for ylabel) **
    quietly summarize id
    local max_id = r(max)

    ** Define the plot with your custom order **
    twoway ///
        (scatter id beta if id == 1, msymbol(D) mcolor(navy)) ///
        (rcap lci uci id if id == 1, horizontal lcolor(navy)) ///
        (scatter id beta if id == 2, msymbol(D) mcolor(sienna)) ///
        (rcap lci uci id if id == 2, horizontal lcolor(sienna)) ///
        (scatter id beta if id == 3, msymbol(D) mcolor(forest_green)) ///
        (rcap lci uci id if id == 3, horizontal lcolor(forest_green)) ///
        (scatter id beta if id == 4, msymbol(D) mcolor(maroon)) ///
        (rcap lci uci id if id == 4, horizontal lcolor(maroon)) ///
        (scatter id beta if id == 5, msymbol(D) mcolor(purple)) ///
        (rcap lci uci id if id == 5, horizontal lcolor(purple)) ///
        (scatter id beta if id == 6, msymbol(D) mcolor(teal)) ///
        (rcap lci uci id if id == 6, horizontal lcolor(teal)) ///
        (scatter id beta if id == 7, msymbol(D) mcolor(lime)) ///
        (rcap lci uci id if id == 7, horizontal lcolor(lime)) ///
        (scatter id beta if id == 8, msymbol(D) mcolor(dkgreen)) ///
        (rcap lci uci id if id == 8, horizontal lcolor(dkgreen)) ///
        (scatter id beta if id == 9, msymbol(D) mcolor(orange)) ///
        (rcap lci uci id if id == 9, horizontal lcolor(orange)) ///
        (scatter id beta if id == 10, msymbol(D) mcolor(cranberry)) ///
        (rcap lci uci id if id == 10, horizontal lcolor(cranberry)) ///
        (scatter id beta if id == 11, msymbol(D) mcolor(blue)) ///
        (rcap lci uci id if id == 11, horizontal lcolor(blue)), ///
        ylabel(1(1)`max_id', valuelabel labsize(vsmall) angle(0)) /// Dynamic y-axis with custom labels
        ytitle("Dependent Variable") ///
        xtitle("Regression Coefficient (95% CI)") ///
        title("Association of IQ at Age 8 with Outcomes at Age `vage'", size(medium)) ///
        legend(order(1 "BMI" 3 "Waist Circumference" 5 "Systolic BP" 7 "Diastolic BP" ///
                     9 "Cholesterol" 11 "HDL" 13 "LDL" 15 "Triglycerides" 17 "Glucose Metabolism" 19 "Insulin" 21 "Carotid Femoral PWV") ///
               size(small) pos(3) col(1)) /// Legend adjusted for pairs
        xline(0, lpattern(dash) lcolor(black)) ///
        plotregion(color(white)) graphregion(color(white))

    ** Export the graph **
    //graph export "output\z_iq8_age`vage'_all_depvars_custom.png", width(2000) height(1200) replace
    graph export "output\z_iq8_age`vage'_exposures_plot_by_age_cfpwv.png", width(2000) height(1200) replace

    restore
}
