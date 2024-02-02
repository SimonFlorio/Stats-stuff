aipw_strata <- function(dataset,...) {
  
  require("dplyr")
  tempdata <- select(dataset,...)
  colnames(tempdata) <- c("yvar","tvar","svar",colnames(tempdata)[4:ncol(tempdata)])
  
  tempdata <- tempdata %>% group_by(svar) %>% mutate(pr_treat = mean(tvar))
  tempdata$yhat_1 <- suppressWarnings(predict(lm(as.formula(paste("yvar", "~", paste(colnames(tempdata)[4:(ncol(tempdata)-1)], collapse = " + "), sep="")), data = tempdata[tempdata$tvar==1,]), newdata = tempdata))
  tempdata$yhat_0 <- suppressWarnings(predict(lm(as.formula(paste("yvar", "~", paste(colnames(tempdata)[4:(ncol(tempdata)-2)], collapse = " + "), sep="")), data = tempdata[tempdata$tvar==0,]), newdata = tempdata))
  tempdata <- tempdata %>% mutate(aipw_te = yhat_1 + (tvar/pr_treat) * (yvar - yhat_1)
                                  - (yhat_0 + ((1 - tvar)/(1 - pr_treat)) * (yvar - yhat_0)))
  return(summary(lm(aipw_te ~ 1, data = tempdata))$coefficients[1,c(1,2)])
  
}