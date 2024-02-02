/* Outcomes in Table 1 of Field et al. (2013) */ global loan_use_vars ///
"Business_Expenditures Non_Business_Exp New_Business_Ap15"
/* Outcomes in Table 2 of Field et al. (2013) */ global profits_vars ///
"Profit ln_Q50 Capital"
/* Outcomes in Table 3 (left) of Field et al. (2013) */ global default_vars ///
"Late_Days_364 Late_Days_476 not_finished_aug19 Outstanding_Loan"
/* Outcomes in Table 3 (right) of Field et al. (2013) */ global repayment_vars ///
"Fifty_Percent_Loan_Paid Made_First_11 Made_First_Pay"
/* Outcomes in Table 4 (left) of Field et al. (2013) */ global business_vars ///
"atleastone Max_Min Q68"
/* Outcomes in Table 4 (right) of Field et al. (2013) */ global customers_vars ///
"Q35_ Q37_ Q11_Together_max"
global last_dvars "$default_vars $repayment_vars $business_vars $customers_vars"
global all_dvars "$loan_use_vars $profits_vars $last_dvars"