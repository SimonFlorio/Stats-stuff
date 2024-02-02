all_dvars <- c("Business_Expenditures", "Non_Business_Exp", "New_Business_Ap15",
               "Profit", "ln_Q50", "Capital", "Late_Days_364", "Late_Days_476",
               "not_finished_aug19", "Outstanding_Loan_Amount_Default", 
               "Fifty_Percent_Loan_Paid", "Made_First_11_Pay_On_Time", 
               "Made_First_Pay", "atleastone_bizshutdown_alt", "Max_Min", "Q68",
               "Q35_", "Q37_", "Q11_Together_max")

loan_use_vars <- c("Business_Expenditures", "Non_Business_Exp", "New_Business_Ap15")

profits_vars <- c("Profit", "ln_Q50", "Capital")

last_dvars <- c("Late_Days_364", "Late_Days_476",
                "not_finished_aug19", "Outstanding_Loan_Amount_Default", 
                "Fifty_Percent_Loan_Paid", "Made_First_11_Pay_On_Time", 
                "Made_First_Pay", "atleastone_bizshutdown_alt", "Max_Min", "Q68",
                "Q35_", "Q37_", "Q11_Together_max")

baseline_vars <- c("factor(Stratification_Dummies)", "factor(sec_loanamount)", "Age_C", 
                   "Married_C", "Muslim_C", "HH_Size_C", "Years_Education_C",
                   "shock_any_C", "Has_Business_C", "Financial_Control_C",
                   "homeowner_C", "No_Drain_C")

miss_ind_vars <- c("miss_Age_C", "miss_Married_C", "miss_Literate_C",
                   "miss_Muslim_C", "miss_HH_Size_C", "miss_Years_Education_C",
                   "miss_shock_any_C", "miss_Has_Business_C", 
                   "miss_Financial_Control_C", "miss_homeowner_C",
                   "miss_sec_loanamount", "miss_No_Drain_C")

baseline_xvars <- c("Age_C", "Married_C", "Muslim_C", "HH_Size_C", "Years_Education_C",
                    "shock_any_C", "Has_Business_C", "Financial_Control_C", 
                    "homeowner_C", "No_Drain_C", "sec_loanamount", "loan_officer1",
                    "loan_officer2", "loan_officer3", "loan_officer4", "loan_amount1",
                    "loan_amount2", "loan_amount3", "stratum1", "stratum2", "stratum3",
                    "stratum4", "stratum5", "stratum6", "stratum7", "stratum8")