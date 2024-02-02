install.packages("dplyr")
install.packages("pbapply")
install.packages("haven")

setwd(file.path(getwd(),"/simulations"))
source("observed_estimates.R")
source("bootstrap_dist.R")
source("randomization_dist.R")

setwd(file.path(getwd(),"../outputs"))
source("appended_results.R")
source("table_single_pvals.R")
source("table_stepdown_pvals.R")