global aer_103_6_2196_data: env aer_103_6_2196_data

do ate_estimators.do

program estimatesx, rclass

use $aer_103_6_2196_data/Grace-Period-Data.dta, clear

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

simulate $storeresults, seed(12345) reps(1) saving("../../store/obs_estimates.dta", replace): estimatesx

timer off 1
timer list 1
timer clear 1
