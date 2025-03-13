*Globals
clear all
local varlist geo1_am2001 geo1_bj2013 geo1_bo2012 geo1_br2010 geo1_kh2013 geo1_co2005 geo1_cr2011 geo1_do2010 geo1_ec2010 geo1_sv2007 geo1_gh2010 geo1_gt2002 geo1_ht2003 geo1_hn2001 geo1_ir2006 geo1_la2005 geo1_ls2006 geo1_lr2008 geo1_ml2009 geo1_mx2015 geo1_mz2007 geo1_np2011 geo1_ni2005 geo1_pe2007 geo1_rw2002 geo1_sn2002 geo1_sl2015 geo1_sd2008 geo1_tz2012 geo1_tg2010 geo1_ve2001 geo1_zm2000 

local domains Elec mort Lit Water

* Iterate over each variable in the list
foreach var in `varlist' { 
    * Load your large database
    use "${di1}ipums_countries_final.dta", clear
    
	
    * Keep only the observations where the variable is not missing
    keep if `var' != .
    
    * Decode the variable and generate a string variable
    decode `var', generate(geo)
   if "`var'" == "geo1_rw2002" {  
        replace geo="North" if inlist(geo, "Byumba", "Ruhengeri")
        replace geo="South" if inlist(geo, "Gikongoro", "Gitarama", "Butare")
        replace geo="West" if inlist(geo, "Cyangugu", "Gisenyi", "Kibuye") 
        replace geo="East" if inlist(geo, "Kibungo", "Umutara") 
    }    
    * Delete the original variable
    drop `var'
	
*Water supply - Services
preserve
drop if (watsup==0 | watsup==99 | watsup==.)
keep if pernum==1
gen ypiped=1 if watsup!=20
gen totwatsup=1
collapse (sum) ypiped totwatsup [pw=hhwt], by (sample country geo year)
gen yes_watsup=ypiped*100/totwatsup
keep geo year yes_watsup sample country
tempfile tempdata_Water_`var'
save "`tempdata_Water_`var''", replace

restore

*Electricity - Services
preserve
	keep if pernum==1
    keep if electric==1 | electric==2
gen yelectric=1 if electric==1
gen nelectric=1 if electric==2
gen totelectric=1
collapse (sum) yelectric nelectric totelectric [pw=hhwt], by (sample country geo year)
gen yes_electric=yelectric*100/totelectric
keep geo year yes_electric sample country
*Create tempfile
	tempfile tempdata_Elec_`var'
	save "`tempdata_Elec_`var''", replace
restore

*Child mortality - Healthcare 
preserve
        drop if (chborn == 98 | chborn == 99 | chborn == .)
        drop if (chsurv == 98 | chsurv == 99 | chsurv == .)
        
        gen deathchild = chborn - chsurv
        collapse (sum) deathchild chborn [pweight=perwt], by (sample country geo year)
        gen child_mortality = deathchild * 1000 / chborn
        keep geo year child_mortality sample country
        
        // Save the dataset if calculations are performed
			tempfile tempdata_mort_`var'
        save "`tempdata_mort_`var''", replace
restore	

*Literacy - Education
preserve
drop if (lit==0 | lit==9 | lit==.)
gen literate=1 if lit==2
gen totlit=1
collapse (sum) literate totlit [pweight=perwt], by (sample country geo year)
gen literate_perc=literate*100/totlit
keep geo year literate_perc sample country
tempfile tempdata_Lit_`var'
save "`tempdata_Lit_`var''", replace
restore

*Merging and appending
foreach var2 in `domains' {
	if ("`var2'"=="Elec") {
		use "`tempdata_`var2'_`var''", clear
	}
	else {
		merge 1:1 sample country geo year using "`tempdata_`var2'_`var''", nogen
	}
tempfile temp_IPUMS_Domains_`var'
save "`temp_IPUMS_Domains_`var''", replace
	}
}

clear 
foreach var in `varlist' {
    // Append using the temporary file
    ap using "`temp_IPUMS_Domains_`var''"
}

*Saving database
save ${do1}IPUMS_countries, replace

*Using database
use ${do1}IPUMS_countries, clear
// List of variables to exclude from renaming
local exclude_vars country year sample geo

// Add "_new" extension to all variables except the excluded ones
foreach var of varlist * {
    // Check if the current variable is in the list of excluded variables
    local is_excluded 0
    foreach excluded_var in `exclude_vars' {
        if "`var'" == "`excluded_var'" {
            local is_excluded 1
            break
        }
    }
    // Rename the variable if it is not in the list of excluded variables
    if `is_excluded' == 0 {
        local newname ind_`var'
        rename `var' `newname'
    }
}



*Reshape the dataset to obtain the desired format
reshape long ind_, i(country year sample geo) j(variable) string
rename variable indicator_original
rename ind_ value_original
rename country countryname
rename geo region
*Factor variables. Helpful to create the value_vector variable 
gen factor= 1000

*Creating the vector_variable
gen value_vector= factor - value_original if (indicator_original=="child_mortality")
replace value_vector=value_original if value_vector==.

*Creating the indicator_variable. This variabe shows the new name given to the original variable after being transformed
gen indicator_vector=indicator_original if (indicator_original!="child_mortality")
replace indicator_vector="child_surv" if indicator_original=="child_mortality"

*Generating new definitions
gen new_definition_vector=""
replace new_definition_vector="Number of children surviving per 1,000 live births" if indicator_original=="child_mortality"
replace new_definition_vector="Percentage of literate people in region. A person is typically considered literate if he or she can both read and write. All other persons are illiterate, including those who can either read or write but cannot do both" if indicator_original=="literate_perc"
replace new_definition_vector="Percentage of households with electricity in region" if indicator_original=="yes_electric"
replace new_definition_vector="Percentage of household with piped water in region" if indicator_original=="yes_watsup"

*Original definitions
gen definition_original=new_definition_vector if (indicator_original!="child_mortality")
replace definition_original="Number of deaths of children, per 1000 live births" if indicator_original=="child_mortality"


*Dropping unnecesary variables
drop factor

*Grouping variables into domains
gen domain=""
replace domain="Health" if (indicator_original=="child_mortality")
replace domain="Service Delivery" if (indicator_original=="yes_electric" | indicator_original=="yes_watsup")
replace domain="Education" if (indicator_original=="literate_perc")

*Generating source variable
gen source="IPUMS"

*Organizing the database
order countryname sample year region domain indicator_original definition_original value_original source indicator_vector new_definition_vector value_vector

*Exporting the database
export excel using "${do1}ipums_state_density_countries_final.xlsx", sheet("IPUMS") replace firstrow(variables)

*Iso codes
import excel "${di1}CLASS.xlsx", sheet("List of economies") firstrow clear
rename Economy countryname 
rename Code countrycode
rename Region continent 
replace countryname="Iran" if countryname=="Iran, Islamic Rep."
replace countryname="Laos" if countryname=="Lao PDR"
replace countryname="Venezuela" if countryname=="Venezuela, RB"
keep countryname countrycode continent
drop if countryname==""
save ${do1}countries_iso, replace

*Merging with the database containing info on iso codes
import excel using "${do1}ipums_state_density_countries_final.xlsx", sheet("IPUMS") firstrow clear
merge m:1 countryname using "${do1}countries_iso.dta"
keep if _merge==3
drop _merge
gen level="Subnat"
gen unit="Household" if (indicator_original=="yes_electric" | indicator_original=="yes_watsup")
replace unit="Individual" if (indicator_original=="child_mortality" | indicator_original=="literate_perc")

preserve
gen id =1
collapse (sum) id, by (countryname region)
drop id
bysort countryname (region): gen reg_id = _n 
save ${do1}IPUMS_region_lab, replace
restore

merge m:1 countryname region using ${do1}IPUMS_region_lab
tostring reg_id, replace
gen region_lab = "reg_" + reg_id
drop _merge reg_id
egen region_code = concat(countrycode region_lab), punct(_)
destring year, replace

* Order the data
order countryname countrycode sample continent year region region_lab region_code level domain indicator_original definition_original unit value_original indicator_vector new_definition_vector value_vector source

export excel using "${do1}ipums_state_density_countries_final.xlsx", sheet("IPUMS")replace firstrow(variables)

*Data for the model - Section 5

local varlist geo1_bo2012 geo1_br2010 geo1_co2005 geo1_cr2011 geo1_ec2010 geo1_sv2007 geo1_gt2002 geo1_mx2015 geo1_ni2005

local domains Area Elec mort Lit For Pop Urban Water Indig

* Iterate over each variable in the list
foreach var in `varlist' { 
    * Load the large dataset
    use "${di1}ipums_countries_controls_final.dta", clear
    
	
    * Keep only the observations where the variable is not missing
    keep if `var' != .
    
    * Decode the variable and generate a string variable
    decode `var', generate(geo)
    
    * Delete the original variable
    drop `var'
	


*Water supply - Services
preserve
drop if (watsup==0 | watsup==99 | watsup==.)
keep if pernum==1
gen ypiped=1 if watsup!=20
gen totwatsup=1
collapse (sum) ypiped totwatsup [pw=hhwt], by (sample country geo year)
gen yes_watsup=ypiped*100/totwatsup
keep geo year yes_watsup sample country
tempfile tempdata_con_Water_`var'
save "`tempdata_con_Water_`var''", replace
restore

*Electricity - Services
preserve
	keep if pernum==1
    keep if electric==1 | electric==2
gen yelectric=1 if electric==1
gen nelectric=1 if electric==2
gen totelectric=1
collapse (sum) yelectric nelectric totelectric [pw=hhwt], by (sample country geo year)
gen yes_electric=yelectric*100/totelectric
keep geo year yes_electric sample country
*Create tempfile
	tempfile tempdata_con_Elec_`var'
	save "`tempdata_con_Elec_`var''", replace
restore

*Child mortality - Healthcare 
preserve
        drop if (chborn == 98 | chborn == 99 | chborn == .)
        drop if (chsurv == 98 | chsurv == 99 | chsurv == .)
        
        gen deathchild = chborn - chsurv
        collapse (sum) deathchild chborn [pweight=perwt], by (sample country geo year)
        gen child_mortality = deathchild * 1000 / chborn
        keep geo year child_mortality sample country
        
        // Add chsurv count to the dataset
        *gen chsurv_count = non_missing_chsurv
        
        // Save the dataset if calculations are performed
			tempfile tempdata_con_mort_`var'
        save "`tempdata_con_mort_`var''", replace
restore	

*Literacy - Education
preserve
drop if (lit==0 | lit==9 | lit==.)
gen literate=1 if lit==2
gen totlit=1
collapse (sum) literate totlit [pweight=perwt], by (sample country geo year)
gen literate_perc=literate*100/totlit
keep geo year literate_perc sample country
tempfile tempdata_con_Lit_`var'
save "`tempdata_con_Lit_`var''", replace
restore

*Nativity status
preserve
drop if (nativity==0 | nativity==9 | nativity==.)
gen foreign=1 if nativity==2
gen totnativity=1
collapse (sum) foreign totnativity [pweight=perwt], by (sample country geo year)
gen foreign_perc=foreign*100/totnativity
keep geo year foreign_perc sample country
tempfile tempdata_con_For_`var'
save "`tempdata_con_For_`var''", replace
restore

*Population Density
preserve
collapse (mean) popdensgeo1, by (sample country geo year)
*Create tempfile
	tempfile tempdata_con_Pop_`var'
	save "`tempdata_con_Pop_`var''", replace
restore

*Urban
preserve
keep if pernum==1  
drop if (urban==9 | urban==.)
gen urbanh=1 if urban==2
gen toturban=1
collapse (sum) urbanh toturban [pweight=hhwt], by (sample country geo year)
gen urbanh_perc=urbanh*100/toturban
keep geo year urbanh_perc sample country
tempfile tempdata_con_Urban_`var'
save "`tempdata_con_Urban_`var''", replace
restore

*Area
preserve
collapse (mean) areamollwgeo1, by (sample country geo year)
*Create tempfile
	tempfile tempdata_con_Area_`var'
	save "`tempdata_con_Area_`var''", replace
restore

*Member of an indigenous group
preserve
drop if (indig==0 | indig==9 | indig==.)
gen indigroup=1 if indig==1
gen totindig=1
collapse (sum) indigroup totindig [pweight=perwt], by (sample country geo year)
gen indig_perc=indigroup*100/totindig
keep geo year indig_perc sample country
tempfile tempdata_con_Indig_`var'
save "`tempdata_con_Indig_`var''", replace
restore

*Merging and appending
foreach var2 in `domains' {
	if ("`var2'"=="Area") {
		use "`tempdata_con_`var2'_`var''", clear
	}
	else {
		merge 1:1 sample country geo year using "`tempdata_con_`var2'_`var''", nogen
	}
tempfile temp_IPUMS_con_Dom_`var'
save "`temp_IPUMS_con_Dom_`var''", replace
	}
}

clear 
foreach var in `varlist' {
    ap using "`temp_IPUMS_con_Dom_`var''"
}

*Labeling data
label variable yes_electric   "Percentage of households with electricity in the region"
label variable yes_watsup   "Percentage of households with electricity in the region"
label variable child_mortality   "Number of children surviving per 1,000 live births"
label variable literate_perc   "Percentage of literate people in the region"
label variable areamollwgeo1   "Area of GEOLEV1 unit in square kilometers"
label variable popdensgeo1   "Population density in persons per square kilometer in the region"
label variable urbanh_perc   "Percentage of households located in a place designated as urban"
label variable indig_perc   "Percentage of people belonging to an indigenous group"
label variable foreign_perc   "Percentage of foreign people in the region"

*Saving database
save ${do1}IPUMS_controls_countries, replace

*Additional changes
use  ${do1}IPUMS_controls_countries, clear
keep country year sample geo yes_electric child_mortality literate_perc yes_watsup areamollwgeo1 foreign_perc popdensgeo1 urbanh_perc indig_perc
rename geo region 
rename country countryname
*Exporting database
export excel using "${do1}IPUMS_controls_countries.xlsx", replace firstrow(variables)


