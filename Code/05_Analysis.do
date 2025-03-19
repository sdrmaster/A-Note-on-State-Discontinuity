clear all

*Import Effectiveness dataset
preserve
use "${do2}Effectiveness.dta", clear
gen id=1
collapse (mean) id, by (countryname region adminregion )
drop id
gen number = 1
collapse (sum) number, by (countryname adminregion )
sort adminregion countryname
egen total_number = total(number)
gen share=number*100/total_number
drop total_number
order adminregion countryname number share
*Table 3
export delimited using "${tab}tab3_countries.csv", replace
restore

*Access World Bank databases
wbopendata, indicators(SI.POV.DDAY) long latest clear
tempfile pov
save `pov'

*Import the dataset
import delimited "${do2}Discontinuity.csv", clear

reshape wide discontinuity, i(countrycode  year_ipums) j(theta)
rename discontinuity* discontinuity_*
merge m:1 countrycode using `pov'
keep if _merge!=2
drop _merge
replace adminregion = "EAP" if countrycode=="KHM"
replace countryname = "Cambodia" if countrycode=="KHM"
replace regionname = "East Asia and Pacific" if countrycode=="KHM"
replace region = "EAS" if countrycode=="KHM"

merge 1:m countrycode using "${do2}Density.dta"
drop _merge
rename year year_sipovdday

sort region_code
order countryname countrycode  region regionname adminregion adminregionname incomelevel incomelevelname lendingtype lendingtypename region_code si_pov_dday discontinuity_* density_* year_ipums year_acled year_sipovdday 
 
merge 1:1 region_code using "${do2}Normalized_Values.dta"
assert _merge==3
drop _merge

rename *_norm *
save "${do2}IPUMS_ACLED_Normalized_Value_Density_Discontinuity.dta", replace

*-------------------------------------------------------------------------------
* Bump Chart with Discontinuity 
*-------------------------------------------------------------------------------
use "${do2}IPUMS_ACLED_Normalized_Value_Density_Discontinuity.dta", clear

collapse (mean) discontinuity_*, by(countryname countrycode adminregion year_ipums) 

tab countryname
local n=r(r)

local theta "5 10 20"
foreach t of local theta{
	gsort -discontinuity_`t'
	gen rank_`t'=_n	
	replace discontinuity_`t' = round(discontinuity_`t', 0.0001)
}



* Create table to be exported in Latex
keep countryname countrycode adminregion discontinuity_5 discontinuity_10 discontinuity_20 rank_5 rank_10 rank_20 
gen delta_5 = rank_5-rank_10
gen delta_2 = rank_20-rank_10
egen countrycode_region = concat(countrycode adminregion), punct(_)

estpost tabstat discontinuity_5 discontinuity_10 discontinuity_20 rank_5 rank_10 rank_20 delta_5 delta_2, by(countryname)

*Table 4
esttab using "${tab}tab4_discontinuity.tex", cells("discontinuity_5 discontinuity_10 discontinuity_20 rank_5 rank_10 rank_20 delta_5 delta_2") noobs nomtitle ///
nonumber varlabels(`e(labels)') drop(Total) varwidth(30) ///
collab(, lhs("`:var lab countryname'")) replace

local theta "5 10 20"
foreach t of local theta{
replace rank_`t' = `n'-rank_`t'+1
}

reshape long discontinuity_ rank_, i(countryname countrycode adminregion) j(theta)
replace theta = 15 if theta==20

*Figure 4
bumpline rank_ theta, by(countryname) scheme(white_tableau) xlabel(5 "0.5" 10 "1" 15 "2") xtitle("value of theta") ylabel(, angle(0))
graph export "${fig}fig4_Bumpgraph_Discontinuity.png", as(png) replace


*-------------------------------------------------------------------------------
* Box Graphs with Density
*-------------------------------------------------------------------------------
clear all
use "${do2}IPUMS_ACLED_Normalized_Value_Density_Discontinuity.dta", clear

local theta "5 10 20"
foreach t of local theta{
	sort density_`t'
	cap	gen density_r_`t'=_n	
	xtile density_pc_`t' = density_`t', nq(10)
}


local theta "5 10 20"
foreach t of local theta{
	if `t'==5{
		local title=0.5
	}
	if `t'==10{
		local title=1
	}
		if `t'==20{
		local title=2
	}


#delimit;
graph box density_r_`t', 
	over(countryname, sort(discontinuity_`t') label(angle(90) labsize(vsmall))) 
	ylabel(0(50)550, angle(0)) ytitle("") 
	scheme(white_tableau)
	aspectratio(1)
	graphregion(
			style(none)
			color(white)
			fcolor(white)
			lstyle(none)
			lcolor(white)
			lwidth(thin)
			)
	ytitle("Country Rank" "(1-lowest density)")
	title("{&theta}=`title'", size(small))
	;
#delimit cr
*Figure 2
graph export "${fig}fig2_hbox_Density_r_`t'.png", as(png) replace
}


label var density_pc_5  "theta=0.5"
label var density_pc_20 "theta=2"
label var density_pc_10 "theta=1"


#delimit ;
alluvial density_pc_5  density_pc_10 density_pc_20,
gap(0);
#delimit cr
*Figure 3
graph export "${fig}fig3.png", as(png) replace

local theta "5 10 20"
foreach t of local theta{
bysort countryname: egen max_density_`t' = max(density_`t')
bysort countryname: 	egen min_density_`t' = min(density_`t')
bysort countryname: 	egen mean_density_`t' = mean(density_`t')
bysort countryname: 	egen sd_density_`t' = mdev(density_`t')	
bysort countryname: 	egen min_density_pc_`t' = min(density_pc_`t')	
bysort countryname: 	egen max_density_pc_`t' = max(density_pc_`t')	
bysort countryname: 	egen min_density_r_`t' = min(density_r_`t')	
bysort countryname: 	egen max_density_r_`t' = max(density_r_`t')	
bysort countryname: 	gen  delta_density_pc_`t' = max_density_pc_`t' - min_density_pc_`t'
bysort countryname: 	gen  delta_density_r_`t' = max_density_r_`t' - min_density_r_`t'
}

collapse (mean)  min_density_* max_density_* mean_density_* delta_density_*, by(countryname)

sort delta_density_r_10
br countryname *10*


*-------------------------------------------------------------------------------
* Effectiveness Analysis
*-------------------------------------------------------------------------------
clear all
use "${do2}IPUMS_ACLED_Normalized_Value_Density_Discontinuity.dta", clear

local var "child_surv literate_perc no_violence yes_electric yes_watsup"
foreach v of local var{
	set seed 123
	sort `v'
	gen `v'_r = _n
	xtile pc_`v' = `v'_r, nq(10)
}

sort adminregion countryname admin1 pc_*
br adminregion countryname admin1 pc_*

cap erase "${tab}text_numbers.tex" 
local var "child_surv literate_perc no_violence yes_electric yes_watsup"
foreach v in `var' {
    tabout adminregion pc_`v' if pc_`v'==1 using "${tab}text_numbers.tex", append cells(freq col)  
}


*-------------------------------------------------------------------------------
* Sankey Graphs
*-------------------------------------------------------------------------------
* Generate Dataset
*-------------------------------------------------------------------------------
clear all
use  "${do2}IPUMS_ACLED_Normalized_Value_Density_Discontinuity.dta", clear

keep region countryname region_code admin1 child_surv-yes_watsup
rename region var1
encode(var1), gen(regioncode)
order var1 regioncode countryname region_code admin1 yes_watsup yes_electric literate_perc child_surv  no_violence  

local var "yes_watsup yes_electric literate_perc child_surv no_violence"
foreach v of local var{
xtile d_`v'=`v', nq(10)
drop `v'
}

preserve
drop d_literate_perc d_child_surv  d_no_violence
gen by = "A"
gen transition = "water_electr"
rename d_yes_watsup from 
rename d_yes_electric to
tempfile A
save `A'
restore

preserve
drop d_yes_watsup d_child_surv d_no_violence
gen by = "B"
gen transition = "electr_edu"
rename d_yes_electric from 
rename d_literate_perc to
tempfile B
save `B'
restore

preserve
drop  d_yes_watsup d_yes_electric d_no_violence
gen by = "C"
gen transition = "edu_health"
rename d_literate_perc from
rename d_child_surv to
tempfile C
save `C'
restore

preserve
drop d_yes_watsup d_yes_electric d_literate_perc
gen by = "D"
gen transition = "health_security"
rename d_child_surv from
rename d_no_violence to
tempfile D
save `D'
restore

use `A', clear
append using `B'
append using `C'
append using `D'

gen value=1
* By regioncode (EAP ECA LAC MNA SAS SSA)

forvalues v=1(1)6{
	if `v'==1 local title = "East Asia and Pacific"
	if `v'==2 local title = "Europe and Central Asia"
	if `v'==3 local title = "Latin America and the Carribbean"
	if `v'==4 local title = "Middle East and North Africa"
	if `v'==5 local title = "South Asia"
	if `v'==6 local title = "Sub-Saharan Africa"

	if `v'==1 local graph = "EAP"
	if `v'==2 local graph = "ECA"
	if `v'==3 local graph = "LAC"
	if `v'==4 local graph = "MNA"
	if `v'==5 local graph = "SAS"
	if `v'==6 local graph = "SSA"

#delimit ;
sankey value if regioncode==`v', from(from) to(to) by(by) 
gap(0)
novalues  
ctitles("Water" "Electricity" "Education" "Health" "Security")
recenter(bot) ctpos(top) ctgap(0) ctcolor(black) offset(0) 
title("`title'")  
palette(CET I2)
xsize(100) ysize(100)
	graphregion(
			style(none)
			color(white)
			fcolor(white)
			lstyle(none)
			lcolor(white)
			lwidth(thin)
			)
;
#delimit cr
*Figure 1
graph export "${fig}fig1_sankey_`graph'.png", as(png) replace
}
