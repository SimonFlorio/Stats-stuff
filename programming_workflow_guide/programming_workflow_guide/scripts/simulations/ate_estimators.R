source(file.path(getwd(),"../programs/aipw_strata.R"))
source(file.path(getwd(),"outcomes.R"))

ate_estimators <- function(dataset) {

require("dplyr")

ctrl_est <- NULL
i <- 0
for (dvar in all_dvars) {
  i <- i + 1
  ctrl_est[i] <- mean(dataset[dataset$sec_treat == 0,][[as.name(dvar)]], na.rm=TRUE)
  ### equivalent to:
  # assign(paste0(dvar,"_ctrl_est"),
  #        mean(dataset[dataset$sec_treat == 0,][[as.name(dvar)]], na.rm=TRUE))
  # ctrl_est[i] <- get(paste0(dvar,"_ctrl_est"))
}
rm(i,dvar)

loan_use_vars_ols1 <- unlist(lapply(loan_use_vars, function(x) {
  lm(substitute(i ~ sec_treat + factor(Stratification_Dummies) + 
                  factor(sec_loanamount) + Match3rd_in3rd, list(i = as.name(x))),
     data = dataset)$coefficients[2]
}))


profits_vars_ols1 <- unlist(lapply(profits_vars, function(x) {
  lm(substitute(i ~ sec_treat + factor(Stratification_Dummies),
                list(i = as.name(x))), data = dataset)$coefficients[2]
}))

last_dvars_ols1 <- unlist(lapply(last_dvars, function(x) {
  lm(substitute(i ~ sec_treat + factor(Stratification_Dummies),
                list(i = as.name(x))), data = dataset)$coefficients[2]
}))

ols1_est <- unname(c(loan_use_vars_ols1, profits_vars_ols1, last_dvars_ols1))
rm(loan_use_vars_ols1, profits_vars_ols1, last_dvars_ols1)

loan_use_vars_ols2 <- NULL
i <- 0
for (dvar in loan_use_vars) {
  i <- i + 1
  loan_use_vars_ols2[i] <- lm(as.formula(paste(dvar, "~",
  paste(c("sec_treat", baseline_vars, miss_ind_vars, "Match3rd_in3rd"),
  collapse = " + "), sep="")), data = dataset)$coefficients[2]
}

profits_vars_ols2 <- NULL
i <- 0
for (dvar in profits_vars) {
  i <- i + 1
  profits_vars_ols2[i] <- lm(as.formula(paste(dvar, "~",
  paste(c("sec_treat", baseline_vars, miss_ind_vars, "factor(sec_loan_officer)"),
  collapse = " + "), sep="")), data = dataset)$coefficients[2]
}

last_dvars_ols2 <- NULL
i <- 0
for (dvar in last_dvars) {
  i <- i + 1
  last_dvars_ols2[i] <- lm(as.formula(paste(dvar, "~",
  paste(c("sec_treat", baseline_vars, miss_ind_vars, "factor(sec_loan_officer)",
  "Literate_C"), collapse = " + "), sep="")), data = dataset)$coefficients[2]
}

ols2_est <- unname(c(loan_use_vars_ols2, profits_vars_ols2, last_dvars_ols2))
rm(loan_use_vars_ols2, profits_vars_ols2, last_dvars_ols2)

for (bvar in baseline_vars[3:length(baseline_vars)]) {
  dataset[dataset[,all_of(paste0("miss_",bvar))]==1, all_of(bvar)] <- NA
}
rm(bvar)

loanofficerids <- as.numeric(rownames(table(dataset$sec_loan_officer)))
for (i in 1:length(loanofficerids)) {
  dataset[,paste0("loan_officer",i)] <- ifelse(dataset$sec_loan_officer == loanofficerids[i], 1, 0)
}

dataset$loan_amount1 <- ifelse(dataset$sec_loanamount %in% c(4000,5000), 1, 0)
dataset$loan_amount2 <- ifelse(dataset$sec_loanamount %in% c(6000,7000), 1, 0)
dataset$loan_amount3 <- ifelse(dataset$sec_loanamount %in% c(8000,9000), 1, 0)
dataset$loan_amount4 <- ifelse(dataset$sec_loanamount == 10000, 1, 0)

group_level_dataset <- dataset %>% group_by(sec_group_name) %>%
                       summarize_all(mean, na.rm = TRUE)

strata_ids <- as.numeric(rownames(table(dataset$Stratification_Dummies)))
for (i in 1:length(strata_ids)) {
  group_level_dataset[,paste0("stratum",i)] <- 
    ifelse(group_level_dataset$Stratification_Dummies == strata_ids[i], 1, 0)
}

aipw_est <- NULL
aipw_tst <- NULL
i <- 0
for (dvar in all_dvars) {
  i <- i + 1
  aipw_stats_temp <- aipw_strata(group_level_dataset, as.name(dvar), sec_treat,
                                 Stratification_Dummies, all_of(baseline_xvars))
  aipw_est[i] <- aipw_stats_temp[1]
  aipw_tst[i] <- aipw_stats_temp[1]/aipw_stats_temp[2]
  rm(aipw_stats_temp)
}
rm(i,dvar)

temp_dataframe <- data.frame(matrix(ncol = length(all_dvars), nrow = 5))
temp_dataframe[1:5,] <- rbind(ctrl_est, ols1_est, ols2_est, aipw_est, aipw_tst)
rownames(temp_dataframe) <- c("ctrl_est", "ols1_est",
                              "ols2_est", "aipw_est", "aipw_tst")
colnames(temp_dataframe) <- all_dvars
return(temp_dataframe)

}