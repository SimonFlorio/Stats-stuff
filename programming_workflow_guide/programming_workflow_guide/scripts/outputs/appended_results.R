loan_use_vars <- c("Business_Expenditures", "Non_Business_Exp", "New_Business_Ap15")
profits_vars <- c("Profit", "ln_Q50", "Capital")
default_vars <- c("Late_Days_364", "Late_Days_476",
                "not_finished_aug19", "Outstanding_Loan_Amount_Default")
repayment_vars <- c("Fifty_Percent_Loan_Paid", "Made_First_11_Pay_On_Time",
                    "Made_First_Pay")
business_vars <- c("atleastone_bizshutdown_alt", "Max_Min", "Q68")
customers_vars <- c("Q35_", "Q37_", "Q11_Together_max")
all_dvars <- c(loan_use_vars, profits_vars, default_vars,
               repayment_vars,business_vars,customers_vars)

library(dplyr, warn.conflicts = FALSE)

obs_estimates <- readRDS("../../store/obs_estimates")
boot_dist <- readRDS("../../store/boot_dist")
rand_dist <- readRDS("../../store/rand_dist")

bootstrap_se <- data.frame(matrix(ncol = length(all_dvars), nrow = 3))
col_num = 0
for (dvar in all_dvars) {
  col_num <- col_num + 1
  boot_se <- t(data.frame(t(matrix(unlist(lapply(boot_dist, 
             function(x) x[,c(dvar)])), nrow = 5))) %>% summarize_all(sd))
  bootstrap_se[,col_num] <- boot_se[2:4]
}
rm(boot_se, col_num)
rownames(bootstrap_se) <- c("ols1_bse","ols2_bse", "aipw_bse")
colnames(bootstrap_se) <- all_dvars

exact_single_pval <- data.frame(matrix(ncol = length(all_dvars), nrow = 4))
col_num = 0
for (dvar in all_dvars) {
  col_num <- col_num + 1
  exact_p <- t(data.frame(t(matrix(unlist(lapply(rand_dist,
             function(x) abs(x[,c(dvar)]) >= abs(obs_estimates[,c(dvar)]))), 
             nrow = 5))) %>% summarize_all(mean))
  exact_single_pval[,col_num] <- exact_p[2:5]
}
rm(exact_p, col_num)
rownames(exact_single_pval) <- c("ols1_epv","ols2_epv",
                                 "aipw_epv", "saipw_epv")
colnames(exact_single_pval) <- all_dvars

#### stepdown p-values

source("../programs/stepdown_pval.R")

exact_stepdown_pval <- data.frame(matrix(ncol = length(all_dvars), nrow = 1))
rownames(exact_stepdown_pval) <- "saipw_spv"
colnames(exact_stepdown_pval) <- all_dvars

block_names <- c("loan_use_vars", "profits_vars", "default_vars",
                 "repayment_vars", "business_vars", "customers_vars")

for (i in 1:length(block_names)) {
  block_vars <- get(block_names[i])
  null_t_df <- data.frame(matrix(unlist(lapply(rand_dist,
               function(x) x[5,all_of(block_vars)])), ncol = length(block_vars),
               byrow = TRUE))
  colnames(null_t_df) <- block_vars
  obs_t_vec <- unlist(obs_estimates[5,all_of(block_vars)])
  exact_stepdown_pval[1,all_of(block_vars)] <- 
    stepdown_pval(abs(null_t_df), abs(obs_t_vec))[[1]]
}

#####

estimates <- obs_estimates[1:4,]

appended_results <- rbind(estimates, bootstrap_se, exact_single_pval)
appended_results <- appended_results[c(1,2,5,8,3,6,9,4,7,10,11),]
appended_results <- rbind(appended_results, exact_stepdown_pval)

saveRDS(appended_results, file = "../../store/appended_results")

rm(list = ls(all.names = TRUE))