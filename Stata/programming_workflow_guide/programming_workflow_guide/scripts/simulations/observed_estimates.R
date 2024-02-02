source(file.path(getwd(),"ate_estimators.R"))

library(dplyr, warn.conflicts = FALSE)
library(haven)

grace_period_data_path <- Sys.getenv("aer_103_6_2196_data")
gpdata <- read_dta(file=file.path(grace_period_data_path,"Grace-Period-Data.dta"))

obs_estimates <- ate_estimators(gpdata)
saveRDS(obs_estimates, file = "../../store/obs_estimates")

rm(list = ls(all.names = TRUE))