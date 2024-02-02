clear all
set more off
version 17.0

use "../../store/appended_results.dta", clear
do "../simulations/outcomes.do"

global note "\textit{Note}: For each outcome of interest, this table reports the control mean, augmented inverse probability weighting (AIPW) estimate of the average treatment effect (ATE), and the following three $ p$-values for testing sharp null hypotheses of no treatment effects: exact single $ p$-value based on the nonstudentized AIPW test statistic; exact single $ p$-value based on the studentized AIPW test statistic; and exact stepdown $ p$-value based on the studentized AIPW test statistic. The latter $ p$-value (i.e., the stepdown $ p$-value) accounts for multiple testing but not the former two single $ p$-values. The blocks of outcomes used for multiple testing are separated in the above table using a horizontal divider line."

local l_Business_Expenditures "Total business spending"
local l_Non_Business_Exp "Total nonbusiness spending"
local l_New_Business_Ap15 "New business"
local l_Profit "Average weekly profits"
local l_ln_Q50 "Log of monthly household income"
local l_Capital "Capital"
local l_Late_Days_364 "Not repaid 8 weeks after due date"
local l_Late_Days_476 "Not repaid 24 weeks after due date"
local l_not_finished_aug19 "Not repaid 52 weeks after due date"
local l_Outstanding_Loan "Outstanding loan 52 weeks after due date"
local l_Fifty_Percent_Loan_Paid "Repaid at least 50\% of loan"
local l_Made_First_11 "Made first half of repayments on time"
local l_Made_First_Pay "Made first payment"
local l_atleastone "Business closure"
local l_Max_Min "Profit range length"
local l_Q68 "Reapid by selling items at discount"
local l_Q35_ "Customers buy on credit"
local l_Q37_ "Customers pre-order items"
local l_Q11_Together_max "Number of items for sale"

file open latex_table using "../../tables/table_stepdown_pvals_stata.tex", write replace

local alignment_line "l|cc|ccc"

file write latex_table "\begin{table}[!ht]" _n
file write latex_table "\begin{center}" _n
file write latex_table "\caption{\textit{\textbf{Stepdown inference on impacts of grace period for microfinance loans (using Stata)}}}" _n
file write latex_table "\label{table:table_stepdown_pvals_stata}" _n
file write latex_table "\scriptsize \vspace{2mm}" _n
file write latex_table "\setstretch{1.5}" _n
file write latex_table "\begin{tabular}{`alignment_line'}" _n
file write latex_table "\hline\hline" _n

local header_line1 " &  &  & \textit{Nonstudentized}  & \textit{Studentized} & \textit{Studentized} "
local header_line2 " & \textit{Control} & \textit{Augmented IPW} & \textit{test-based exact} & \textit{test-based exact} & \textit{test-based exact} "
local header_line3 " \textit{Outcome} & \textit{mean} & \textit{estimate of ATE} & \textit{single $ p$-value} & \textit{single $ p$-value} & \textit{stepdown $ p$-value} "

foreach dvar in $all_dvars {
	local `dvar'_ctrl = `dvar'[1]
	local row = 7
	foreach stat in est bse epn eps sdp {
		local row = `row' + 1
		local `dvar'_`stat' = `dvar'[`row']
		if ``dvar'_`stat'' <= 0.1 {
			local `dvar'_`stat'_l "\mathbf {"
			local `dvar'_`stat'_r "}"
		}
		else {
			local `dvar'_`stat'_l ""
			local `dvar'_`stat'_r ""
		}
	}
		
	
	local `dvar'_line "`l_`dvar'' & $ `: di %5.2f ``dvar'_ctrl' ' $ & $ `: di %5.2f ``dvar'_est' ' $"
	foreach stat in epn eps sdp {
		local `dvar'_line "``dvar'_line' & $ ``dvar'_`stat'_l' `: di %5.4f ``dvar'_`stat'' ' ``dvar'_`stat'_r' $"
	}

}

file write latex_table "`header_line1' \\ [-1mm]" _n
file write latex_table "`header_line2' \\ [-1mm]" _n
file write latex_table "`header_line3' \\ \hline " _n

local blocknum = 0
foreach block in loan_use profits default repayment business customers {
	local dvarnum = 0
	local blocknum = `blocknum' + 1
	foreach dvar in ${`block'_vars} {
		local dvarnum = `dvarnum' + 1
		file write latex_table " $ (`blocknum'.`dvarnum') $ ``dvar'_line' \\ " _n
	}
	file write latex_table "\hline" _n
}

file write latex_table "\hline" _n
file write latex_table "\end{tabular}" _n
file write latex_table "\end{center} \vspace{-2mm}" _n
file write latex_table "\setstretch{1}\noindent \scriptsize" _n
file write latex_table "$note" _n
file write latex_table "\end{table}" _n

file close latex_table