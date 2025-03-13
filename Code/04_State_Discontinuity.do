clear all
*Create empty file to store results
cap file open Discontinuity using "${do2}Discontinuity.csv", write text replace

import excel "${do1}ipums_state_density_countries_final.xlsx", sheet("IPUMS") firstrow clear


tostring year, gen(year_string)
egen country_year = concat(countrycode year_string), punct(_)
bysort countrycode: egen max_year=max(year)
keep if year==max_year
drop max_year

* merge with ACLED violence data
append using "${do2}ACLED_merged_final"

gen year_acled = year if source=="ACLED"
gen year_ipums = year if source=="IPUMS"
drop year year_string

gen admin1 = strlower(region)

replace countrycode="ZMB" if countrycode=="ZWB"
replace countrycode="PSE" if countryname=="Palestine"
replace countryname="West Bank and Gaza" if countryname=="Palestine"

preserve
*ssc install wbopendata
wbopendata, indicators(SI.POV.DDAY) long latest clear
tempfile pov
save `pov'
restore

merge m:1 countrycode using `pov'
replace regionname = "East Asia and Pacific" if countryname=="Cambodia"
replace regionname = "Middle East and North Africa" if countryname=="West Bank and Gaza"
replace adminregion = "EAP" if countryname=="Cambodia"
replace adminregion = "MNA" if countryname=="Palestine"

* Drop countries with very old census data 
drop if year_ipums<2000

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
*Select indicators
keep if indicator_vector=="child_surv" | indicator_vector=="literate_perc" | indicator_vector=="yes_electric" | indicator_vector=="yes_watsup"| indicator_vector=="no_violence"


*Creating local based on the number of selected indicators
levelsof indicator_vector, local(values_dim)
local count_ind_num: word count `values_dim'

*Keep only the regions with complete information
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
save "${do2}Effectiveness.dta", replace

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

preserve 
keep value_norm indicator_vector countryname countrycode continent region region_code admin1
reshape wide value_norm, i(countryname countrycode continent region region_code admin1) j(indicator_vector) string
rename value_normchild_surv child_surv_norm
rename value_normliterate_perc literate_perc_norm
rename value_normno_violence no_violence_norm
rename value_normyes_electric yes_electric_norm
rename value_normyes_watsup yes_watsup_norm
gen basic_services_norm= (yes_electric_norm + yes_watsup_norm)/2
*drop yes_electric_norm yes_watsup_norm
save "${do2}Normalized_Values.dta", replace
restore 

collapse (mean) density* year_acled year_ipums, by(countryname countrycode region region_code admin1 continent)

save "${do2}Density.dta", replace

local n 1
	if `n'==1{
	file write Discontinuity "countrycode,year_acled,year_ipums,theta,discontinuity" _n

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
 
file write Discontinuity "`c',`year_acled',`year_ipums',`t',`discontinuity_`t''" _n

} // theta
restore
} // countrycode
local ++n
} // n
file close Discontinuity

