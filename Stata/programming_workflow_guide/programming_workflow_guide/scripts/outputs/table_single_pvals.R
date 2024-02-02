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

block_names <- c("loan_use_vars", "profits_vars", "default_vars",
                 "repayment_vars", "business_vars", "customers_vars")

library(dplyr, warn.conflicts = FALSE)

ar <- readRDS("../../store/appended_results")

l_Business_Expenditures <- "Total business spending"
l_Non_Business_Exp <- "Total nonbusiness spending"
l_New_Business_Ap15 <- "New business"
l_Profit <- "Average weekly profits"
l_ln_Q50 <- "Log of monthly household income"
l_Capital <- "Capital"
l_Late_Days_364 <- "Not repaid 8 weeks after due date"
l_Late_Days_476 <- "Not repaid 24 weeks after due date"
l_not_finished_aug19 <- "Not repaid 52 weeks after due date"
l_Outstanding_Loan_Amount_Default <- "Outstanding loan 52 weeks after due date"
l_Fifty_Percent_Loan_Paid <- "Repaid at least 50\\% of loan"
l_Made_First_11_Pay_On_Time <- "Made first half of repayments on time"
l_Made_First_Pay <- "Made first payment"
l_atleastone_bizshutdown_alt <- "Business closure"
l_Max_Min <- "Profit range length"
l_Q68 <- "Reapid by selling items at discount"
l_Q35_ <- "Customers buy on credit"
l_Q37_ <- "Customers pre-order items"
l_Q11_Together_max <- "Number of items for sale"


latex_lines <- c("\\begin{table}[!ht]", "\\begin{center}",
"\\caption{\\textit{\\textbf{Impact of grace period on business activity and repayment outcomes (using R)}}}",
"\\label{table:table_single_pvals_r}", "\\scriptsize \\vspace{2mm}",
"\\setstretch{1.5}",
"\\begin{tabular}{l|c@{\\hskip 10pt}|c@{\\hskip 10pt}|c@{\\hskip 10pt}|c}",
"\\hline\\hline",
" & \\textit{Control} & \\textit{Simple OLS} & \\textit{Adjusted OLS} & \\textit{Augmented IPW} \\\\ [-1mm]",
" \\textit{Outcome} & \\textit{mean} & \\textit{estimate of ATE} & \\textit{estimate of ATE} & \\textit{estimate of ATE} \\\\ \\hline \\hline")

fileTeX <-file("../../tables/table_single_pvals_r.tex")
writeLines(latex_lines, fileTeX)
close(fileTeX)

blocknum <- 0

for (i in 1:length(block_names)) {
  dvarnum <- 0
  blocknum <- blocknum + 1
  for (dvar in get(block_names[i])) {
    
    dvarnum <- dvarnum + 1

    dvar_line1 <- paste0(" $ (",blocknum,".",dvarnum,") $ ",
                         get(paste0("l_",dvar))," & $ ",
                         format(ar["ctrl_est",dvar], digits=1, nsmall=2)," $ ")
    dvar_line2 <- " & "
    
    for (estim in c("ols1","ols2","aipw")) {
      
      epl <- ifelse(ar[paste0(estim,"_epv"),dvar] <= 0.1," \\mathbf { ","")
      epr <- ifelse(ar[paste0(estim,"_epv"),dvar] <= 0.1," } ","")
      
      dvar_line1 <- paste0(dvar_line1," & $ ",
        format(ar[paste0(estim,"_est"),dvar], digits=1, nsmall=2)," \\;\\; ( ",
        format(ar[paste0(estim,"_bse"),dvar], digits=1, nsmall=2)," ) $ ")
      dvar_line2 <- paste0(dvar_line2," & $ [",epl,
        format(ar[paste0(estim,"_epv"),dvar], digits=0, nsmall=4),epr," ] $")
    }
    
    latex_lines <- c(paste0(dvar_line1,"\\\\ [-1mm]"), paste0(dvar_line2," \\\\ \\hline"))
    write(latex_lines,file="../../tables/table_single_pvals_r.tex",append=TRUE)
  }
  write("\\hline",file="../../tables/table_single_pvals_r.tex",append=TRUE)
}

latex_lines <- c("\\end{tabular}","\\end{center} \\vspace{-2mm}",
                 "\\setstretch{1}\\noindent \\scriptsize",
                 "\\textit{Note}: For each outcome of interest, the above table reports the control mean and three ATE estimates (based on simple OLS, adjusted OLS, and augmented IPW methods) along with their bootstrap standard errors in parentheses (next to the estimates). Below each ATE estimate is its exact $ p$-value (reported within brackets) based on a randomization test using the raw estimate as the test statistic without studentization.","\\end{table}")
write(latex_lines,file="../../tables/table_single_pvals_r.tex",append=TRUE)

rm(list = ls(all.names = TRUE))