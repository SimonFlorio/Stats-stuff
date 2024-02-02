ssc install rowranks, replace

program stepdown_pval

	local nvarlists "`1'"
	forval i = 1/`nvarlists' {
		local stepdown_dvlist`i' "``=`i'+1''"
		di "`stepdown_dvlist`i''"
	}
	forval j = 1/`nvarlists' {
		global temp_vvlist ""
		global temp_vlist `stepdown_dvlist`j''
		foreach var in $temp_vlist {
			global temp_vvlist "$temp_vvlist `var'"
		}
		global vlist`j' $temp_vvlist
	}

	forval j = 1/`nvarlists' {

		qui {

			local varlist: display "${vlist`j'}"
			local numoutcomes: word count `varlist'
			di `numoutcomes'

			foreach var in `varlist' {
				gen t_`var' = `var'
			}

			foreach var in `varlist' {
				if t_`var'[1] < 0 {
					replace t_`var' = - t_`var'
				}
			}

			local tvarlist ""
			foreach var in `varlist' {
				local tvarlist "`tvarlist' t_`var'"
			}
			local tt0varlist ""
			foreach var in `varlist' {
				local tt0varlist "`tt0varlist' tt0_`var'"
			}
			local ttvarlist ""
			foreach var in `varlist' {
				local ttvarlist "`ttvarlist' tt_`var'"
			}
			//ssc install rowranks
			rowranks `tvarlist', gen(`tt0varlist') field lowrank
			foreach tt0var in `tt0varlist' {
				replace `tt0var' = . if _n > 1
			}

			local incr = 0
			foreach tt0var in `tt0varlist' {
				local incr = `incr' + 1/(3 * `numoutcomes')
				replace `tt0var' = `tt0var' + `incr'
			}

			//the "3" is arbitrary.. anything above 1 should work

			rowranks `tt0varlist', gen(`ttvarlist')

			drop `tt0varlist'
			// tt0varlist was created and modified to avoid any ties
			// after getting ttvarlist, we're dropping tt0varlist


			// use the ranks per se to generate p1, p2, ..., p6
			// then, make a local to store rank of a variable
			// then p_`variable' = p`local_rank'


			forval s = 1/`numoutcomes' {

				local currentvar ""

				foreach var in `varlist' {
					replace tt_`var' = t_`var' if _n > 1 & tt_`var'[1] >= `s'
					if tt_`var'[1] == `s' {
						local currentvar "`var'"
					}
				}

				egen maxtt = rowmax(`ttvarlist') if _n > 1

				count if maxtt >= t_`currentvar'[1] & _n > 1
				local p`s'init = (r(N) + 1)/(_N)

				if `s' == 1 {
					local p`s'adj = min(1,`p`s'init')
				}

				if `s' > 1 {
					local sm1 = `s' - 1
					local p`s'adj = min(1,max( `p`s'init' , `p`sm1'adj' ))
				}

				replace `currentvar' = `p`s'adj' if _n==1

				foreach var in `varlist' {
					replace tt_`var' = . if _n > 1
				}

				drop maxtt
			}

			drop t_* tt_*

		}

		di "Romano-Wolf stepdown procedure for block " `j' " complete"

	}


	drop if _n > 1

end