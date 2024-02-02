
*** Estimates ***

foreach estim in ctrl ols1 ols2 aipw {
	use "../../store/obs_estimates.dta", clear
	keep *_`estim'_est
	rename *_`estim'_est *
	
	tempfile estimate_`estim'
	save "`estimate_`estim''"
}

*** Bootstrap standard errors ***

foreach estim in ols1 ols2 aipw {
	use "../../store/boot_dist.dta", clear
	keep *_`estim'_est
	rename *_`estim'_est *
	collapse (sd) *
	
	tempfile boot_se_`estim'
	save "`boot_se_`estim''"
}

*** Exact p-values for nonstudentized test statistics ***

foreach estim in ols1 ols2 aipw {
	use "../../store/obs_estimates.dta", clear
	append using "../../store/rand_dist.dta"
	keep *_`estim'_est
	rename *_`estim'_est *
	ds
	local variable_list "`r(varlist)'"
	foreach var in `variable_list' {
		replace `var' = abs(`var')
		gen temp_`var' = (`var' >= `var'[1])
		drop `var'
		rename temp_`var' `var'
	}
	collapse (mean) *
	
	tempfile exact_p_`estim'_est
	save "`exact_p_`estim'_est'"
}

*** Exact p-values for studentized AIPW test statistic ***

foreach estim in aipw {
	use "../../store/obs_estimates.dta", clear
	append using "../../store/rand_dist.dta"
	keep *_`estim'_tst
	rename *_`estim'_tst *
	ds
	local variable_list "`r(varlist)'"
	foreach var in `variable_list' {
		replace `var' = abs(`var')
		gen temp_`var' = (`var' >= `var'[1])
		drop `var'
		rename temp_`var' `var'
	}
	collapse (mean) *
	
	tempfile exact_p_`estim'_tst
	save "`exact_p_`estim'_tst'"
}


*** Stepdown p-values ***

do ../programs/stepdown_pval.do

use "../../store/obs_estimates.dta", clear
append using "../../store/rand_dist.dta"
keep *_aipw_tst
rename *_aipw_tst *
ds
local variable_list "`r(varlist)'"
foreach var in `variable_list' {
	replace `var' = abs(`var')
}


stepdown_pval "6" ///
"Business_Expenditures Non_Business_Exp New_Business_Ap15" ///
"Profit ln_Q50 Capital" ///
"Late_Days_364 Late_Days_476 not_finished_aug19 Outstanding_Loan" ///
"Fifty_Percent_Loan_Paid Made_First_11 Made_First_Pay" ///
"atleastone Max_Min Q68" ///
"Q35_ Q37_ Q11_Together_max"

tempfile stepdown_p_aipw
save "`stepdown_p_aipw'"

*** Appended results ***

use "`estimate_ctrl'", clear

foreach estim in ols1 ols2 aipw {
	append using "`estimate_`estim''"
	append using "`boot_se_`estim''"
	append using "`exact_p_`estim'_est'"
}

append using "`exact_p_aipw_tst'"
append using "`stepdown_p_aipw'"

save "../../store/appended_results.dta", replace