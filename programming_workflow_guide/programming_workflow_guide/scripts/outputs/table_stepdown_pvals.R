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
"\\caption{\\textit{\\textbf{Stepdown inference on impacts of grace period for microfinance loans (using R)}}}",
"\\label{table:table_stepdown_pvals_r}", "\\scriptsize \\vspace{2mm}",
"\\setstretch{1.5}",
"\\begin{tabular}{l|cc|ccc}",
"\\hline\\hline",
"&  &  & \\textit{Nonstudentized}  & \\textit{Studentized} & \\textit{Studentized} \\\\ [-1mm]",
" & \\textit{Control} & \\textit{Augmented IPW} & \\textit{test-based exact} & \\textit{test-based exact} & \\textit{test-based exact} \\\\ [-1mm]",
"\\textit{Outcome} & \\textit{mean} & \\textit{estimate of ATE} & \\textit{single $ p$-value} & \\textit{single $ p$-value} & \\textit{stepdown $ p$-value} \\\\ \\hline")

fileTeX <-file("../../tables/table_stepdown_pvals_r.tex")
writeLines(latex_lines, fileTeX)
close(fileTeX)

blocknum <- 0
for (i in 1:length(block_names)) {
  dvarnum <- 0
  blocknum <- blocknum + 1
  for (dvar in get(block_names[i])) {
    dvarnum <- dvarnum + 1

    dvar_line <- paste0(" $ (",blocknum,".",dvarnum,") $ ",
                         get(paste0("l_",dvar))," & $ ",
                         format(ar["ctrl_est",dvar], digits=1, nsmall=2)," $ ")
    
      
      dvar_line <- paste0(dvar_line," & $ ",
        format(ar["aipw_est",dvar], digits=1, nsmall=2)," $ ")
      
      for (stat in c("aipw_epv","saipw_epv","saipw_spv")) {
        epl <- ifelse(ar[all_of(stat),dvar] <= 0.1," \\mathbf { ","")
        epr <- ifelse(ar[all_of(stat),dvar] <= 0.1," } ","")
        dvar_line <- paste0(dvar_line," & $ ",epl,
                            format(ar[all_of(stat),dvar], digits=0, nsmall=4),epr," $")
      }
      
    
    latex_lines <- paste0(dvar_line,"\\\\")
    write(latex_lines,file="../../tables/table_stepdown_pvals_r.tex",append=TRUE)
  }
  write("\\hline",file="../../tables/table_stepdown_pvals_r.tex",append=TRUE)
}

latex_lines <- c("\\hline","\\end{tabular}","\\end{center} \\vspace{-2mm}",
                 "\\setstretch{1}\\noindent \\scriptsize",
                 "\\textit{Note}: For each outcome of interest, this table reports the control mean, augmented inverse probability weighting (AIPW) estimate of the average treatment effect (ATE), and the following three $ p$-values for testing sharp null hypotheses of no treatment effects: exact single $ p$-value based on the nonstudentized AIPW test statistic; exact single $ p$-value based on the studentized AIPW test statistic; and exact stepdown $ p$-value based on the studentized AIPW test statistic. The latter $ p$-value (i.e., the stepdown $ p$-value) accounts for multiple testing but not the former two single $ p$-values. The blocks of outcomes used for multiple testing are separated in the above table using a horizontal divider line.","\\end{table}")
write(latex_lines,file="../../tables/table_stepdown_pvals_r.tex",append=TRUE)

rm(list = ls(all.names = TRUE))