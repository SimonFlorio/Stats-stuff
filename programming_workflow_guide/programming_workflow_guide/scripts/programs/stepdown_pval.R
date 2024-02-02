stepdown_pval <- function(null_tstats_dataframe, obs_tstats_vec) {
  
  require("dplyr")
  
  S <- length(obs_tstats_vec)
  
  # r = indices of highest to lowest observed t-statistics for outcomes
  r <- unlist(sort(obs_tstats_vec, decreasing = TRUE, index.return = TRUE)[2])
  
  maxt <- data.frame(matrix(ncol = S, nrow = nrow(null_tstats_dataframe)))
  colnames(maxt) <- colnames(null_tstats_dataframe)
  for (j in 1:(S-1)) {
    maxt[,r[j]] <- apply(null_tstats_dataframe[,r[j:S]], 1, max)
  }
  maxt[,r[S]] <- null_tstats_dataframe[,r[S]]
  
  stepdown_pval_vec_initial <- NULL
  for (j in 1:S) {
    stepdown_pval_vec_initial[j] <- mean(c(1,maxt[,j] >= obs_tstats_vec[j]))
  }
  stepdown_pval_vec_adjusted <- NULL
  stepdown_pval_vec_adjusted[r[1]] <- stepdown_pval_vec_initial[r[1]]
  for (k in 2:S) {
    stepdown_pval_vec_adjusted[r[k]] <-
      max(stepdown_pval_vec_initial[c(r[k],r[k-1])])
  }
  return(list(stepdown_pval_vec_adjusted,maxt))
  
}