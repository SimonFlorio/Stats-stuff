clear all
set more off
version 17.0

use "../../store/appended_results.dta", clear

do "../simulations/outcomes.do"

*******************************************
global note "\textit{Note}: For each outcome of interest, the above table reports the control mean and three ATE estimates (based on simple OLS, adjusted OLS, and augmented IPW methods) along with their bootstrap standard errors in parentheses (next to the estimates). Below each ATE estimate is its exact $ p$-value (reported within brackets) based on a randomization test using the raw estimate as the test statistic without studentization."

*******************************************

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

file open latex_table using "../../tables/table_single_pvals_stata.tex", write replace

local alignment_line "l|c@{\hskip 10pt}|c@{\hskip 10pt}|c@{\hskip 10pt}|c"

file write latex_table "\begin{table}[!ht]" _n
file write latex_table "\begin{center}" _n
file write latex_table "\caption{\textit{\textbf{Impact of grace period on business activity and repayment outcomes (using Stata)}}}" _n
file write latex_table "\label{table:table_single_pvals_stata}" _n
file write latex_table "\scriptsize \vspace{2mm}" _n
file write latex_table "\setstretch{1.5}" _n
file write latex_table "\begin{tabular}{`alignment_line'}" _n
file write latex_table "\hline\hline" _n

local header_line1 " & \textit{Control} & \textit{Simple OLS} & \textit{Adjusted OLS} & \textit{Augmented IPW} "
local header_line2 " \textit{Outcome} & \textit{mean} & \textit{estimate of ATE} & \textit{estimate of ATE} & \textit{estimate of ATE} "

foreach dvar in $all_dvars {
	local row = 1
	local `dvar'_ctrl = `dvar'[`row']
	foreach estim in ols1 ols2 aipw {
		foreach stat in est bse epv {
			local row = `row' + 1
			local `dvar'_`estim'`stat' = `dvar'[`row']
		}
		if ``dvar'_`estim'epv' <= 0.1 {
			local `dvar'_`estim'epl "\mathbf {"
			local `dvar'_`estim'epr "}"
		}
		else {
			local `dvar'_`estim'epl ""
			local `dvar'_`estim'epr ""
		}
	}
	
	local `dvar'_line1 "`l_`dvar'' & $ `: di %5.2f ``dvar'_ctrl' ' $"
	local `dvar'_line2 " & "
	foreach estim in ols1 ols2 aipw {
		local `dvar'_line1 "``dvar'_line1' & $ `: di %5.2f ``dvar'_`estim'est' ' "
		local `dvar'_line1 "``dvar'_line1' \;\; ( `: di %5.2f ``dvar'_`estim'bse' ' ) $ "
		local `dvar'_line2 "``dvar'_line2' & $ [ ``dvar'_`estim'epl' `: di %5.4f ``dvar'_`estim'epv' ' ``dvar'_`estim'epr' ] $"
	}
}


file write latex_table "`header_line1' \\ [-1mm]" _n
file write latex_table "`header_line2' \\ \hline \hline" _n

local blocknum = 0
foreach block in loan_use profits default repayment business customers {
	local dvarnum = 0
	local blocknum = `blocknum' + 1
	foreach dvar in ${`block'_vars} {
		local dvarnum = `dvarnum' + 1
		file write latex_table " $ (`blocknum'.`dvarnum') $ ``dvar'_line1' \\ [-1mm] " _n
		file write latex_table " ``dvar'_line2' \\ \hline " _n
	}
	file write latex_table "\hline" _n
}

file write latex_table "\end{tabular}" _n
file write latex_table "\end{center} \vspace{-2mm}" _n
file write latex_table "\setstretch{1}\noindent \scriptsize" _n
file write latex_table "$note" _n
file write latex_table "\end{table}" _n

file close latex_table