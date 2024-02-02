*-------------------------------------------------------------------------------*
* Augmented inverse probability weighting estimator for stratified experiments  *
*-------------------------------------------------------------------------------*
/*
Note: This file defines a program for estimating the average treatment effect
using the augmented inverse probability weighting (AIPW) estimator for
completely randomized stratified experiments without any missing data.
*/
*----------------------------------- Syntax -----------------------------------*
/*
The syntax is:
aipw_strata "[yvar]" "[tvar]" "[svar]" "[xvars]"
where
[yar] is the name of the outcome variable,
[tvar] is the name of the binary treatment variable,
[svar] is the name of the categorical strata variable, and
[xvars] is the list of baseline covariates.

Example:
aipw_strata "outcome" "treated" "stratum_id" "xvar1 xvar2 xvar3"
*/
*----------------------------------- Program -----------------------------------*

version 17.0

program aipw_strata, rclass

	local yvar "`1'" // outcome variable
	local tvar "`2'" // binary treatment variable
	local svar "`3'" // categorical strata variable
	local xvars "`4'" // baseline covariates

	egen _pr_treat = mean(`tvar'), by(`svar') // strata-based propensity score
	reg `yvar' `xvars' if `tvar'==1 // regression model for treated units
	predict _yhat_1
	reg `yvar' `xvars' if `tvar'==0 // regression model for untreated units
	predict _yhat_0
	gen _aipw_te = (_yhat_1 + (`tvar'/_pr_treat) * (`yvar' - _yhat_1)) ///
	- (_yhat_0 + ((1 - `tvar')/(1 - _pr_treat)) * (`yvar' - _yhat_0))
	reg _aipw_te, robust // AIPW estimator
	return scalar aipw_strata_est = _b[_cons] // store AIPW estimate
	return scalar aipw_strata_se = _se[_cons] // store its standard error
	drop _pr_treat _yhat_1 _yhat_0 _aipw_te // revert dataset to prior state

end
