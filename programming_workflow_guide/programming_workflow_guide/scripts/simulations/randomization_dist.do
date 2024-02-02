set seed 12345

net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/") replace
mata mata mlib index

global aer_103_6_2196_data: env aer_103_6_2196_data
global current_dir: pwd

do outcomes.do

program randx, rclass

cap program drop aipw_strata
cap program drop ate_estimators
cd $current_dir
do ate_estimators.do

use $aer_103_6_2196_data/Grace-Period-Data.dta, clear

gen id = _n
egen group_id = group(sec_group_name)
bysort group_id (id): gen temp_ind = 1 if _n==1
replace temp_ind = 2 if temp_ind==.
egen number_treated = total(sec_treat) if temp_ind==1, by(Stratification_Dummies) 
gen rand_uniform = runiform()
sort temp_ind Stratification_Dummies rand_uniform
bysort temp_ind Stratification_Dummies: gen temp_num = _n
gen randomized_sec_treat_temp = (temp_num <= number_treated) if temp_ind==1
egen randomized_sec_treat = mean(randomized_sec_treat_temp), by(sec_group_name)
sort id
replace sec_treat = randomized_sec_treat
drop id group_id temp_ind number_treated rand_uniform ///
temp_num randomized_sec_treat_temp randomized_sec_treat

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

//simulate $storeresults, reps(2000) saving("../../store/rand_dist.dta", replace every(10)): randx

parallel initialize
parallel sim, expr($storeresults) reps(2000) randtype(current) saving("../../store/rand_dist.dta", replace every(10)): randx
parallel clean

timer off 1
timer list 1
timer clear 1