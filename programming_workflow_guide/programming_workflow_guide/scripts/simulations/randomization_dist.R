ptm <- proc.time()

set.seed(12345)

library(parallel)
library(pbapply)

cl <- makeCluster(round(detectCores() * 0.75))

clusterEvalQ(cl, {

## START OF CODE BLOCK 1 ##
  
source(file.path(getwd(),"ate_estimators.R"))

library(dplyr, warn.conflicts = FALSE)
library(haven)
  
grace_period_data_path <- Sys.getenv("aer_103_6_2196_data")
gpdata <- read_dta(file=file.path(grace_period_data_path,"Grace-Period-Data.dta"))

gpdata_cluster_vars <- gpdata %>% 
  select(sec_group_name, Stratification_Dummies, sec_treat) %>%
  group_by(sec_group_name) %>% filter(row_number() == 1)

table(gpdata_cluster_vars$sec_treat, gpdata_cluster_vars$Stratification_Dummies)

## END OF CODE BLOCK 1 ##

})

randomization_test_estimates <- function(...) {
  
  ## START OF CODE BLOCK 2 ##
  
  cluster_vars_temp <- gpdata_cluster_vars
  cluster_vars_temp$streat <-
    ave(cluster_vars_temp$sec_treat, cluster_vars_temp$Stratification_Dummies, FUN = sample)
  sum(cluster_vars_temp$streat != cluster_vars_temp$sec_treat)
  cluster_vars_temp <- select(cluster_vars_temp, sec_group_name, streat)
  gpdata_temp <- left_join(gpdata, cluster_vars_temp,
                           by = c(sec_group_name = "sec_group_name"))
  sum(gpdata_temp$streat != gpdata_temp$sec_treat)
  gpdata_temp <- gpdata_temp %>% mutate(sec_treat = streat)
  gpdata_temp <- gpdata_temp[,!(names(gpdata_temp) %in% c("streat"))]
  
  return(ate_estimators(gpdata_temp))
  
  ## END OF CODE BLOCK 2 ##
  
}
  
# rand_dist_temp <- parLapply(cl, 1:2000, randomization_test_estimates)
system.time(rand_dist <- pblapply(1:2000, randomization_test_estimates, cl = cl))

stopCluster(cl)

saveRDS(rand_dist, file = "../../store/rand_dist")

proc.time() - ptm

rm(list = ls(all.names = TRUE))


#####################################

### ALTERNATIVE CODE:

# set.seed(12345)
# 
# ## BLOCK 1 ##
# 
# randomization_test_estimates <- function(...) {
#   ## BLOCK 2 ##
# }
# 
# rand_dist <- list()
# 
# for (sim_num in 1:2000) {
#   rand_dist[[sim_num]] <- randomization_test_estimates()
#   print(sim_num)
# }
# 
# saveRDS(rand_dist, file = "../../store/rand_dist")