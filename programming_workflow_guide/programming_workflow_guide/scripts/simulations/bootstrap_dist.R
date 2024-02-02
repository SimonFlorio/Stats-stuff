ptm <- proc.time()

set.seed(12345)

library(parallel)
library(pbapply)

cl <- makeCluster(round(detectCores() * 0.75))

clusterEvalQ(cl, {

source(file.path(getwd(),"ate_estimators.R"))

library(dplyr, warn.conflicts = FALSE)
library(haven)

grace_period_data_path <- Sys.getenv("aer_103_6_2196_data")
gpdata <- read_dta(file=file.path(grace_period_data_path,"Grace-Period-Data.dta"))

gpdata_cluster_vars <- gpdata %>% 
  select(sec_group_name, Stratification_Dummies, sec_treat) %>%
  group_by(sec_group_name) %>% filter(row_number() == 1)

table(gpdata_cluster_vars$sec_treat, gpdata_cluster_vars$Stratification_Dummies)

})

bootstrap_estimates <- function(...) {
  
  gpdata_temp <- data.frame(matrix(nrow = 1, ncol = ncol(gpdata)))
  colnames(gpdata_temp) <- colnames(gpdata)
  
  row_count <- 0
  
  for (i in unique(gpdata$Stratification_Dummies)) {
    for (j in unique(gpdata$sec_treat)) {
      cluster_vars_temp <- gpdata_cluster_vars %>%
        filter(Stratification_Dummies==i & sec_treat==j)
      vec_temp <- sample(cluster_vars_temp$sec_group_name, replace = TRUE)
      for (k in 1:length(vec_temp)) {
        gpdata_temp[(row_count + 1):(row_count + 5),] <- gpdata %>%
          filter(sec_group_name == vec_temp[k])
        row_count = row_count + 5
      }
    }
  }
  
  
  table(gpdata_temp$sec_treat, gpdata_temp$Stratification_Dummies)
  
  gpdata_temp$sec_group_name <- ceiling(c(1:nrow(gpdata_temp))/5)
  
  return(ate_estimators(gpdata_temp))
  
}

system.time(boot_dist <- pblapply(1:2000, bootstrap_estimates, cl = cl))

stopCluster(cl)

saveRDS(boot_dist, file = "../../store/boot_dist")

proc.time() - ptm

rm(list = ls(all.names = TRUE))