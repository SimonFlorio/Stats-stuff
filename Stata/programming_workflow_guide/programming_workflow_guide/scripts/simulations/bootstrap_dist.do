set seed 12345

net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/") replace
mata mata mlib index

global aer_103_6_2196_data: env aer_103_6_2196_data
global current_dir: pwd

do outcomes.do

program bootx, rclass

cap program drop aipw_strata
cap program drop ate_estimators
cd $current_dir
do ate_estimators.do

use $aer_103_6_2196_data/Grace-Period-Data.dta, clear

bsample, cluster(sec_group_name) strata(Stratification_Dummies sec_treat) idcluster(new_sec_group_name)
drop sec_group_name
gen sec_group_name = new_sec_group_name
drop new_sec_group_name

ate_estimators

foreach dvar in $all_dvars {
	foreach result in ctrl_est ols1_est ols2_est aipw_est aipw_tst {
		return scalar `dvar'_`result' = r(`dvar'_`result')
	}
}

end

global storeresults ""
foreach dvar in $all_dvars {
	foreach result in ctrl_est ols1_est ols2_est aipw_est aipw_tst {
		global storeresults "$storeresults `dvar'_`result' = r(`dvar'_`result')"
	}
}

timer on 1

//simulate $storeresults, reps(2000) saving("../../store/boot_dist.dta", replace every(10)): bootx

parallel initialize
parallel sim, expr($storeresults) reps(2000) randtype(current) saving("../../store/boot_dist.dta", replace every(10)): bootx
parallel clean

timer off 1
timer list 1
timer clear 1
