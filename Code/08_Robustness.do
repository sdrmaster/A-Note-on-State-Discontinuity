clear all
use "${do2}Effectiveness.dta", clear
drop _merge

preserve
wbopendata, indicators(SI.POV.DDAY) long latest clear
tempfile pov
save `pov'
restore

merge m:1 countrycode using `pov'

drop admin1
rename region admin1

tempfile loop
save `loop'

*-------------------------------------------------------------------------------
* Dimensions and indicators
*-------------------------------------------------------------------------------
/* 
* Security
no_violence

* Basic Services
yes_electric
yes_watsup

* Health
child_surv 

* Education
literate_perc
*/

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Select indicators
* For Robustness check we eliminate one indicator at the time
* 1 
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
use `loop', clear
local l=1
cap file open Discontinuity_`l' using "${do2}Discontinuity_`l'.csv", write text replace

keep if indicator_vector=="child_surv" | indicator_vector=="literate_perc" | indicator_vector=="yes_electric" | indicator_vector== "yes_watsup"
*Creating local based on the number of selected indicators
levelsof indicator_vector, local(values_dim)
local count_ind_num: word count `values_dim'

*Keep only the regions with complete information
drop n
bysort countrycode region_code: gen n=_N
drop if n!=`count_ind_num'

*-------------------------------------------------------------------------------
* Normalize
*-------------------------------------------------------------------------------
cap drop value_norm
gen value_norm = .

foreach v of local values_dim{
sum value_vector if indicator_vector=="`v'"
local mean = r(mean)
local min  = r(min)
local max = r(max)
local range = `max'-`min'
replace value_norm = (value_vector - `min') / `range' if indicator_vector=="`v'"
}

foreach v of local values_dim{
	di in red "`v'"
	sum value_norm if indicator_vector=="`v'", det
}


preserve
keep admin1 regionname region_code value_norm indicator_vector
reshape wide value_norm, i(admin1 region_code regionname) j(indicator_vector) string
rename value_norm* *
save "${do2}Normalized_Values_`l'.dta", replace
restore

*-------------------------------------------------------------------------------
* Density
*-------------------------------------------------------------------------------
local theta "5 10 20"
foreach t of local theta{
 	local theta_`t'_10 = `t' / 10
	gen value_norm_`t'_w = value_norm^(`theta_`t'_10') * (1/`count_ind_num')
	bysort region_code: egen test_`t' = total(value_norm_`t'_w ) 
	gen density_`t' = test_`t' ^ ((`theta_`t'_10')^(-1)) 
}

collapse (mean) density* year_acled year_ipums, by(countryname countrycode regionname admin1 region_code)

save "${do2}Density_`l'.dta", replace

local n 1
	if `n'==1{
	file write Discontinuity_`l' "loop,countrycode,year_acled,year_ipums,theta,discontinuity" _n

*-------------------------------------------------------------------------------
* Discontinuity
* Create all pieces for the index: [1/(m*(m-1)*μ*2)] \sum\sum|d_i-d_j|
*-------------------------------------------------------------------------------

*local for loops
levelsof countrycode, local(countrycode_values)

foreach c of local countrycode_values {
*Subset the dataset
preserve 
keep if countrycode=="`c'" 
 
local theta "5 10 20"
foreach t of local theta {


*finding μ     
egen mean_density_`t' = mean(density_`t')

*Sort the dataset by geographical subdivisions
sort region_code

*Initialize index to zeros
gen index_`t' = 0

*Generate the index (\sum\sum|d_i-d_j|)
qui forval i = 1/`=_N' { 
    qui forval j = 1/`=_N' { 
        *Calculate the absolute difference and add it to the index variable
        replace index_`t' = index_`t' + abs(density_`t'[`i'] - density_`t'[`j'])
    }
}

*Generate the constant component (1/(m(m-1)μ * 2))
gen cons_`t'=1/(`=_N'*(`=_N' - 1)*mean_density_`t'*2)

*Generate the discontinuity index D = 1/m(m-1)μ \sum\sum|d_i-d_j|/2

sum year_acled
local year_acled = r(mean)
 
sum year_ipums
local year_ipums = r(mean)
	
gen discontinuity_`t'=cons_`t'*index_`t'

sum discontinuity_`t'
local discontinuity_`t' = r(mean)
 
file write Discontinuity_`l' "`l',`c',`year_acled',`year_ipums',`t',`discontinuity_`t''" _n

} // theta
restore
} // countrycode
local ++n
} // n
file close Discontinuity_`l'

	

	
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Select indicators
* For Robustness check we eliminate one indicator at the time
* 2 
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
use `loop', clear
local l=2
cap file open Discontinuity_`l' using "${do2}Discontinuity_`l'.csv", write text replace

cap file open Discontinuity_`l' using "${do2}Discontinuity_`l'.csv", write text replace
	
	keep if indicator_vector=="child_surv" | indicator_vector=="literate_perc" | indicator_vector=="yes_electric" |  indicator_vector=="no_violence"		
*Creating local based on the number of selected indicators
levelsof indicator_vector, local(values_dim)
local count_ind_num: word count `values_dim'

*Keep only the regions with complete information
drop n
bysort countrycode region_code: gen n=_N
drop if n!=`count_ind_num'

*-------------------------------------------------------------------------------
* Normalize
*-------------------------------------------------------------------------------
cap drop value_norm
gen value_norm = .

foreach v of local values_dim{
sum value_vector if indicator_vector=="`v'"
local mean = r(mean)
local min  = r(min)
local max = r(max)
local range = `max'-`min'
replace value_norm = (value_vector - `min') / `range' if indicator_vector=="`v'"
}

foreach v of local values_dim{
	di in red "`v'"
	sum value_norm if indicator_vector=="`v'", det
}


preserve
keep admin1 regionname region_code value_norm indicator_vector
reshape wide value_norm, i(admin1 region_code regionname) j(indicator_vector) string
rename value_norm* *
save "${do2}Normalized_Values_`l'.dta", replace
restore


*-------------------------------------------------------------------------------
* Density
*-------------------------------------------------------------------------------
local theta "5 10 20"
foreach t of local theta{
 	local theta_`t'_10 = `t' / 10
	gen value_norm_`t'_w = value_norm^(`theta_`t'_10') * (1/`count_ind_num')
	bysort region_code: egen test_`t' = total(value_norm_`t'_w ) 
	gen density_`t' = test_`t' ^ ((`theta_`t'_10')^(-1)) 
}

collapse (mean) density* year_acled year_ipums, by(countryname countrycode regionname admin1 region_code)

save "${do2}Density_`l'.dta", replace

local n 1
	if `n'==1{
	file write Discontinuity_`l' "loop,countrycode,year_acled,year_ipums,theta,discontinuity" _n

*-------------------------------------------------------------------------------
* Discontinuity
* Create all pieces for the index: [1/(m*(m-1)*μ*2)] \sum\sum|d_i-d_j|
*-------------------------------------------------------------------------------

*local for loops
levelsof countrycode, local(countrycode_values)

foreach c of local countrycode_values {
*Subset the dataset
preserve 
keep if countrycode=="`c'" 
 
local theta "5 10 20"
foreach t of local theta {


*finding μ     
egen mean_density_`t' = mean(density_`t')

*Sort the dataset by geographical subdivisions
sort region_code

*Initialize index to zeros
gen index_`t' = 0

*Generate the index (\sum\sum|d_i-d_j|)
qui forval i = 1/`=_N' { 
    qui forval j = 1/`=_N' { 
        *Calculate the absolute difference and add it to the index variable
        replace index_`t' = index_`t' + abs(density_`t'[`i'] - density_`t'[`j'])
    }
}

*Generate the constant component (1/(m(m-1)μ * 2))
gen cons_`t'=1/(`=_N'*(`=_N' - 1)*mean_density_`t'*2)

*Generate the discontinuity index D = 1/m(m-1)μ \sum\sum|d_i-d_j|/2

sum year_acled
local year_acled = r(mean)
 
sum year_ipums
local year_ipums = r(mean)
	
gen discontinuity_`t'=cons_`t'*index_`t'

sum discontinuity_`t'
local discontinuity_`t' = r(mean)
 
file write Discontinuity_`l' "`l',`c',`year_acled',`year_ipums',`t',`discontinuity_`t''" _n

} // theta
restore
} // countrycode
local ++n
} // n
file close Discontinuity_`l'


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Select indicators
* For Robustness check we eliminate one indicator at the time
* 3 
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
use `loop', clear
local l=3
cap file open Discontinuity_`l' using "${do2}Discontinuity_`l'.csv", write text replace

keep if indicator_vector=="child_surv" | indicator_vector=="literate_perc" |  indicator_vector=="yes_watsup"| indicator_vector=="no_violence"
*Creating local based on the number of selected indicators
levelsof indicator_vector, local(values_dim)
local count_ind_num: word count `values_dim'

*Keep only the regions with complete information
drop n
bysort countrycode region_code: gen n=_N
drop if n!=`count_ind_num'

*-------------------------------------------------------------------------------
* Normalize
*-------------------------------------------------------------------------------
cap drop value_norm
gen value_norm = .

foreach v of local values_dim{
sum value_vector if indicator_vector=="`v'"
local mean = r(mean)
local min  = r(min)
local max = r(max)
local range = `max'-`min'
replace value_norm = (value_vector - `min') / `range' if indicator_vector=="`v'"
}

foreach v of local values_dim{
	di in red "`v'"
	sum value_norm if indicator_vector=="`v'", det
}


preserve
keep admin1 regionname region_code value_norm indicator_vector
reshape wide value_norm, i(admin1 region_code regionname) j(indicator_vector) string
rename value_norm* *
save "${do2}Normalized_Values_`l'.dta", replace
restore

*-------------------------------------------------------------------------------
* Density
*-------------------------------------------------------------------------------
local theta "5 10 20"
foreach t of local theta{
 	local theta_`t'_10 = `t' / 10
	gen value_norm_`t'_w = value_norm^(`theta_`t'_10') * (1/`count_ind_num')
	bysort region_code: egen test_`t' = total(value_norm_`t'_w ) 
	gen density_`t' = test_`t' ^ ((`theta_`t'_10')^(-1)) 
}

collapse (mean) density* year_acled year_ipums, by(countryname countrycode regionname admin1 region_code)

save "${do2}Density_`l'.dta", replace

local n 1
	if `n'==1{
	file write Discontinuity_`l' "loop,countrycode,year_acled,year_ipums,theta,discontinuity" _n

*-------------------------------------------------------------------------------
* Discontinuity
* Create all pieces for the index: [1/(m*(m-1)*μ*2)] \sum\sum|d_i-d_j|
*-------------------------------------------------------------------------------

*local for loops
levelsof countrycode, local(countrycode_values)

foreach c of local countrycode_values {
*Subset the dataset
preserve 
keep if countrycode=="`c'" 
 
local theta "5 10 20"
foreach t of local theta {


*finding μ     
egen mean_density_`t' = mean(density_`t')

*Sort the dataset by geographical subdivisions
sort region_code

*Initialize index to zeros
gen index_`t' = 0

*Generate the index (\sum\sum|d_i-d_j|)
qui forval i = 1/`=_N' { 
    qui forval j = 1/`=_N' { 
        *Calculate the absolute difference and add it to the index variable
        replace index_`t' = index_`t' + abs(density_`t'[`i'] - density_`t'[`j'])
    }
}

*Generate the constant component (1/(m(m-1)μ * 2))
gen cons_`t'=1/(`=_N'*(`=_N' - 1)*mean_density_`t'*2)

*Generate the discontinuity index D = 1/m(m-1)μ \sum\sum|d_i-d_j|/2

sum year_acled
local year_acled = r(mean)
 
sum year_ipums
local year_ipums = r(mean)
	
gen discontinuity_`t'=cons_`t'*index_`t'

sum discontinuity_`t'
local discontinuity_`t' = r(mean)
 
file write Discontinuity_`l' "`l',`c',`year_acled',`year_ipums',`t',`discontinuity_`t''" _n

} // theta
restore
} // countrycode
local ++n
} // n
file close Discontinuity_`l'


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Select indicators
* For Robustness check we eliminate one indicator at the time
* 4 
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
use `loop', clear
local l=4
cap file open Discontinuity_`l' using "${do2}Discontinuity_`l'.csv", write text replace

keep if indicator_vector=="child_surv" |  indicator_vector=="yes_electric" | indicator_vector=="yes_watsup"| indicator_vector=="no_violence"		
*Creating local based on the number of selected indicators
levelsof indicator_vector, local(values_dim)
local count_ind_num: word count `values_dim'

*Keep only the regions with complete information
drop n
bysort countrycode region_code: gen n=_N
drop if n!=`count_ind_num'

*-------------------------------------------------------------------------------
* Normalize
*-------------------------------------------------------------------------------
cap drop value_norm
gen value_norm = .

foreach v of local values_dim{
sum value_vector if indicator_vector=="`v'"
local mean = r(mean)
local min  = r(min)
local max = r(max)
local range = `max'-`min'
replace value_norm = (value_vector - `min') / `range' if indicator_vector=="`v'"
}

foreach v of local values_dim{
	di in red "`v'"
	sum value_norm if indicator_vector=="`v'", det
}


preserve
keep admin1 regionname region_code value_norm indicator_vector
reshape wide value_norm, i(admin1 region_code regionname) j(indicator_vector) string
rename value_norm* *
save "${do2}Normalized_Values_`l'.dta", replace
restore

*-------------------------------------------------------------------------------
* Density
*-------------------------------------------------------------------------------
local theta "5 10 20"
foreach t of local theta{
 	local theta_`t'_10 = `t' / 10
	gen value_norm_`t'_w = value_norm^(`theta_`t'_10') * (1/`count_ind_num')
	bysort region_code: egen test_`t' = total(value_norm_`t'_w ) 
	gen density_`t' = test_`t' ^ ((`theta_`t'_10')^(-1)) 
}

collapse (mean) density* year_acled year_ipums, by(countryname countrycode regionname admin1 region_code)

save "${do2}Density_`l'.dta", replace

local n 1
	if `n'==1{
	file write Discontinuity_`l' "loop,countrycode,year_acled,year_ipums,theta,discontinuity" _n

*-------------------------------------------------------------------------------
* Discontinuity
* Create all pieces for the index: [1/(m*(m-1)*μ*2)] \sum\sum|d_i-d_j|
*-------------------------------------------------------------------------------

*local for loops
levelsof countrycode, local(countrycode_values)

foreach c of local countrycode_values {
*Subset the dataset
preserve 
keep if countrycode=="`c'" 
 
local theta "5 10 20"
foreach t of local theta {


*finding μ     
egen mean_density_`t' = mean(density_`t')

*Sort the dataset by geographical subdivisions
sort region_code

*Initialize index to zeros
gen index_`t' = 0

*Generate the index (\sum\sum|d_i-d_j|)
qui forval i = 1/`=_N' { 
    qui forval j = 1/`=_N' { 
        *Calculate the absolute difference and add it to the index variable
        replace index_`t' = index_`t' + abs(density_`t'[`i'] - density_`t'[`j'])
    }
}

*Generate the constant component (1/(m(m-1)μ * 2))
gen cons_`t'=1/(`=_N'*(`=_N' - 1)*mean_density_`t'*2)

*Generate the discontinuity index D = 1/m(m-1)μ \sum\sum|d_i-d_j|/2

sum year_acled
local year_acled = r(mean)
 
sum year_ipums
local year_ipums = r(mean)
	
gen discontinuity_`t'=cons_`t'*index_`t'

sum discontinuity_`t'
local discontinuity_`t' = r(mean)
 
file write Discontinuity_`l' "`l',`c',`year_acled',`year_ipums',`t',`discontinuity_`t''" _n

} // theta
restore
} // countrycode
local ++n
} // n
file close Discontinuity_`l'

	
	
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*Select indicators
* For Robustness check we eliminate one indicator at the time
* 5 
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
use `loop', clear
local l=5
cap file open Discontinuity_`l' using "${do2}Discontinuity_`l'.csv", write text replace


	keep if  indicator_vector=="literate_perc" | indicator_vector=="yes_electric" | indicator_vector=="yes_watsup"| indicator_vector=="no_violence"
*Creating local based on the number of selected indicators
levelsof indicator_vector, local(values_dim)
local count_ind_num: word count `values_dim'

*Keep only the regions with complete information
drop n
bysort countrycode region_code: gen n=_N
drop if n!=`count_ind_num'

*-------------------------------------------------------------------------------
* Normalize
*-------------------------------------------------------------------------------
cap drop value_norm
gen value_norm = .

foreach v of local values_dim{
sum value_vector if indicator_vector=="`v'"
local mean = r(mean)
local min  = r(min)
local max = r(max)
local range = `max'-`min'
replace value_norm = (value_vector - `min') / `range' if indicator_vector=="`v'"
}

foreach v of local values_dim{
	di in red "`v'"
	sum value_norm if indicator_vector=="`v'", det
}


preserve
keep admin1 regionname region_code value_norm indicator_vector
reshape wide value_norm, i(admin1 region_code regionname) j(indicator_vector) string
rename value_norm* *
save "${do2}Normalized_Values_`l'.dta", replace
restore

*-------------------------------------------------------------------------------
* Density
*-------------------------------------------------------------------------------
local theta "5 10 20"
foreach t of local theta{
 	local theta_`t'_10 = `t' / 10
	gen value_norm_`t'_w = value_norm^(`theta_`t'_10') * (1/`count_ind_num')
	bysort region_code: egen test_`t' = total(value_norm_`t'_w ) 
	gen density_`t' = test_`t' ^ ((`theta_`t'_10')^(-1)) 
}

collapse (mean) density* year_acled year_ipums, by(countryname countrycode regionname admin1 region_code)

save "${do2}Density_`l'.dta", replace

local n 1
	if `n'==1{
	file write Discontinuity_`l' "loop,countrycode,year_acled,year_ipums,theta,discontinuity" _n

*-------------------------------------------------------------------------------
* Discontinuity
* Create all pieces for the index: [1/(m*(m-1)*μ*2)] \sum\sum|d_i-d_j|
*-------------------------------------------------------------------------------

*local for loops
levelsof countrycode, local(countrycode_values)

foreach c of local countrycode_values {
*Subset the dataset
preserve 
keep if countrycode=="`c'" 
 
local theta "5 10 20"
foreach t of local theta {


*finding μ     
egen mean_density_`t' = mean(density_`t')

*Sort the dataset by geographical subdivisions
sort region_code

*Initialize index to zeros
gen index_`t' = 0

*Generate the index (\sum\sum|d_i-d_j|)
qui forval i = 1/`=_N' { 
    qui forval j = 1/`=_N' { 
        *Calculate the absolute difference and add it to the index variable
        replace index_`t' = index_`t' + abs(density_`t'[`i'] - density_`t'[`j'])
    }
}

*Generate the constant component (1/(m(m-1)μ * 2))
gen cons_`t'=1/(`=_N'*(`=_N' - 1)*mean_density_`t'*2)

*Generate the discontinuity index D = 1/m(m-1)μ \sum\sum|d_i-d_j|/2

sum year_acled
local year_acled = r(mean)
 
sum year_ipums
local year_ipums = r(mean)
	
gen discontinuity_`t'=cons_`t'*index_`t'

sum discontinuity_`t'
local discontinuity_`t' = r(mean)
 
file write Discontinuity_`l' "`l',`c',`year_acled',`year_ipums',`t',`discontinuity_`t''" _n

} // theta
restore
} // countrycode
local ++n
} // n
file close Discontinuity_`l'


* Analysis

wbopendata, indicators(SI.POV.DDAY) long latest clear
tempfile pov
save `pov'

forvalues l=1(1)5{
import delimited "${do2}Discontinuity_`l'.csv", clear
tempfile Discontinuity_`l'
save `Discontinuity_`l''	
}

use  `Discontinuity_1', clear
forvalues l=2(1)5{
append using  `Discontinuity_`l''	
}

merge m:1 countrycode using `pov'
keep if _merge!=2
drop _merge
replace adminregion = "EAP" if countrycode=="KHM"
replace countryname = "Cambodia" if countrycode=="KHM"
replace regionname = "East Asia and Pacific" if countrycode=="KHM"
replace region = "EAS" if countrycode=="KHM"


*-------------------------------------------------------------------------------
* Bump Chart with Discontinuity 
*-------------------------------------------------------------------------------
drop year_ipums year_acled year lendingtypename lendingtype incomelevelname incomelevel

label define loop  1 "security" 2 "water" 3 "electricity" 4 "education" 5 "health"
label values loop loop

reshape wide discontinuity, i(countryname countrycode adminregionname adminregion loop) j(theta)
reshape wide discontinuity5 discontinuity10 discontinuity20, i(countryname countrycode adminregionname adminregion ) j(loop)
rename discontinuity* discontinuity_*
forvalues i=1(1)5{
	rename *5`i' *5_`i'
	rename *10`i' *10_`i'
	rename *20`i' *20_`i'

}
 

tab countryname
local n=r(r)

local theta "5 10 20"
foreach t of local theta{
	forvalues i=1(1)5{
	
		gsort -discontinuity_`t'_`i'
		gen rank_`t'_`i'=_n	
		replace discontinuity_`t'_`i' = round(discontinuity_`t'_`i', 0.0001)
	}
}

save "${do2}Discontinuity_Robusness_Check.dta", replace
sort countryname
keep countryname discontinuity*
order countryname discontinuity_5_1 discontinuity_5_2 discontinuity_5_3 discontinuity_5_4 discontinuity_5_5 discontinuity_10_1 discontinuity_10_2 discontinuity_10_3 discontinuity_10_4 discontinuity_10_5 discontinuity_20_1 discontinuity_20_2 discontinuity_20_3 discontinuity_20_4 discontinuity_20_5
*Table A3 (from the Appendix)
export delimited using "${annex_tab}tabA3_discontinuity_robust_check.csv", replace 
*-------------------------------------------------------------------------------
* Create Figures for Robustness Checks
*-------------------------------------------------------------------------------
use "${do2}Discontinuity_Robusness_Check.dta", clear
keep countryname rank*

rename rank_*_1 rank_security_*
rename rank_*_2 rank_water_*
rename rank_*_3 rank_electricity_*
rename rank_*_4 rank_education_*
rename rank_5_5	rank_health_5
rename rank_10_5 rank_health_10
rename rank_20_5 rank_health_20

reshape long rank_water_ rank_security_ rank_health_ rank_electricity_ rank_education_, i(countryname) j(theta)
rename *_ *
gen test = 5 if theta==5
replace test=10 if theta==10
replace test=20 if theta==20

drop theta
rename test theta

reshape long rank_, i(countryname theta) j(excluded_var) string
gen excluded_var_code = 1 if excluded_var=="water"
replace excluded_var_code = 2 if excluded_var=="electricity"
replace excluded_var_code = 3 if excluded_var=="education"
replace excluded_var_code = 4 if excluded_var=="health"
replace excluded_var_code = 5 if excluded_var=="security"

label define excluded_var 1"water" 2"electricity" 3"education" 4"health" 5"security"
label values excluded_var_code excluded_var

local ylbls
forvalues i = 1/32 {
    local ylbls `ylbls' `i' "`i'"
}

rename rank_ rank
#delimit;
bumpline rank excluded_var_code if theta==5, 
	by(countryname) scheme(white_tableau)  
	xlabel(1(1)5, valuelabel)
	ylabel(`ylbls', angle(0))
		yscale(reverse) top(32) xtitle("excluded dimension") ytitle("");
#delimit cr
*Figure 5(a)
graph export "${fig}fig5_bumpgraph_robust_05.png", as(png) replace


#delimit;
bumpline rank excluded_var_code if theta==10, 
	by(countryname) scheme(white_tableau)  
	xlabel(1 2 3 4 5, valuelabel)
	ylabel(`ylbls', angle(0))
		yscale(reverse) top(32) xtitle("excluded dimension") ytitle("");
#delimit cr
*Figure 5(b)
graph export "${fig}fig5_bumpgraph_robust_1.png", as(png) replace


#delimit;
bumpline rank excluded_var_code if theta==20, 
	by(countryname) scheme(white_tableau)  
	xlabel(1 2 3 4 5 , valuelabel)
	ylabel(`ylbls', angle(0))
		yscale(reverse) top(32) xtitle("excluded dimension") ytitle("");
#delimit cr
*Figure 5(c)
graph export "${fig}fig5_bumpgraph_robust_2.png", as(png) replace