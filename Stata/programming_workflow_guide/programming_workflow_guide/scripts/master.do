cd simulations
do "observed_estimates.do"
do "bootstrap_dist.do"
do "randomization_dist.do"

cd ../outputs
do "appended_results.do"
do "table_single_pvals.do"
do "table_stepdown_pvals.do"