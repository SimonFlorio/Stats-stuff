
do ../programs/aipw_strata.do
do outcomes.do

program ate_estimators, rclass

local loan_use_vars $loan_use_vars
local profits_vars $profits_vars
local default_vars $default_vars
local repayment_vars $repayment_vars
local business_vars $business_vars
local customers_vars $customers_vars
local last_dvars $last_dvars
local all_dvars $all_dvars

local baseline_vars1 "i.Stratification_Dummies i.sec_loanamount"
local baseline_vars2 "Age_C Married_C Muslim_C HH_Size_C Years_Education_C shock_any_C"
local baseline_vars3 "Has_Business_C Financial_Control_C homeowner_C No_Drain_C"
local baseline_vars "`baseline_vars1' `baseline_vars2' `baseline_vars3'"

gen Outstanding_Loan = Outstanding_Loan_Amount_Default
gen Made_First_11 = Made_First_11_Pay_On_Time
gen atleastone = atleastone_bizshutdown_alt

foreach dvar in `all_dvars' {
	su `dvar' if sec_treat==0
	return scalar `dvar'_ctrl_est = r(mean)
}

foreach dvar in `loan_use_vars' {
	regress `dvar' sec_treat i.Stratification_Dummies ///
	i.sec_loanamount Match3rd_in3rd, cluster(sec_group_name)
	return scalar `dvar'_ols1_est = _b[sec_treat]
	
	regress `dvar' sec_treat `baseline_vars' miss_* ///
	Match3rd_in3rd, cluster(sec_group_name)
	return scalar `dvar'_ols2_est = _b[sec_treat]
}

foreach dvar in `profits_vars' {
	regress `dvar' sec_treat i.Stratification_Dummies, cluster(sec_group_name)
	return scalar `dvar'_ols1_est = _b[sec_treat]
	
	regress `dvar' sec_treat `baseline_vars' miss_* ///
	i.sec_loan_officer, cluster(sec_group_name)
	return scalar `dvar'_ols2_est = _b[sec_treat]
}


foreach dvar in `last_dvars' {
	regress `dvar' sec_treat i.Stratification_Dummies, cluster(sec_group_name)
	return scalar `dvar'_ols1_est = _b[sec_treat]
	
	regress `dvar' sec_treat `baseline_vars' miss_* ///
	i.sec_loan_officer Literate_C, cluster(sec_group_name)
	return scalar `dvar'_ols2_est = _b[sec_treat]
}
 

foreach var in `baseline_vars2' `baseline_vars3' {
	replace `var' = . if miss_`var'==1
}
tab sec_loan_officer, gen(loan_officer)
gen loan_amount1 = inlist(sec_loanamount,4000,5000)
gen loan_amount2 = inlist(sec_loanamount,6000,7000)
gen loan_amount3 = inlist(sec_loanamount,8000,9000)
gen loan_amount4 = inlist(sec_loanamount,10000)

order sec_group_name *
collapse sec_loanamount - loan_amount4, by(sec_group_name) 

local baseline_xvars1 "`baseline_vars2' `baseline_vars3' i.Stratification_Dummies"
local baseline_xvars2 "loan_officer1 loan_officer2 loan_officer3 loan_officer4"
local baseline_xvars3 "sec_loanamount loan_amount1 loan_amount2 loan_amount3"
local baseline_xvars "`baseline_xvars1' `baseline_xvars2' `baseline_xvars3'"

foreach dvar in `all_dvars' {
	aipw_strata "`dvar'" "sec_treat" "Stratification_Dummies" "`baseline_xvars'"
	return scalar `dvar'_aipw_est = r(aipw_strata_est)
	return scalar `dvar'_aipw_tst = r(aipw_strata_est)/r(aipw_strata_se)
}

end