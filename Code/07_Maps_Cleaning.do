*Density
use "${do2}Density.dta", clear
*Selecting countries
keep countryname countrycode continent region region_code year_acled year_ipums density_10
* Sort the data by the variable density_10
sort density_10
* Create the decile variable
xtile decile = density_10, nq(10)
* Convert numeric decile values to string labels if needed
label define decile 1 "Decile 1" 2 "Decile 2" 3 "Decile 3" 4 "Decile 4" 5 "Decile 5" 6 "Decile 6" 7 "Decile 7" 8 "Decile 8" 9 "Decile 9" 10 "Decile 10"
label values decile decile
*Selecting countries
keep if countryname=="Armenia" | countryname=="Benin" | countryname=="Brazil" | countryname=="Laos" | countryname=="Costa Rica" | countryname=="Haiti"| countryname=="Honduras" | countryname=="Mali" | countryname=="Mozambique"
*Brazil
replace region="Rondonia" if (region=="Rondônia" & countryname=="Brazil")
replace region="Para" if (region=="Pará" & countryname=="Brazil")
replace region="Amapa" if (region=="Amapá" & countryname=="Brazil")
replace region="Maranhao" if (region=="Maranhão" & countryname=="Brazil")
replace region="Piaui" if (region=="Piauí" & countryname=="Brazil")
replace region="Espiritu Santo" if (region=="Espírito Santo" & countryname=="Brazil")
replace region="Parana" if (region=="Paraná" & countryname=="Brazil")
replace region="Goias" if (region=="Goiás" & countryname=="Brazil")
*Mozambique 
replace region="Cidade De Maputo" if (region=="Maputo city" & countryname=="Mozambique")
replace region="Maputo" if (region=="Maputo province" & countryname=="Mozambique")
*Country code
gen isoc="geo1_am2001" if countryname=="Armenia"
replace isoc="geo1_bj2013" if countryname=="Benin"
replace isoc="geo1_br2010" if countryname=="Brazil"
replace isoc="geo1_cr2011" if countryname=="Costa Rica"
replace isoc="geo1_hn2001" if countryname=="Honduras"
replace isoc="geo1_ht2003" if countryname=="Haiti"
replace isoc="geo1_la2005" if countryname=="Laos"
replace isoc="geo1_ml2009" if countryname=="Mali"
replace isoc="geo1_mz2007" if countryname=="Mozambique"

*Exporting results
export excel using "${do2}density_maps.xlsx", firstrow (variables) replace

*Effectiveness
* Define the list of indicators
local indicators "child_surv literate_perc no_violence yes_electric yes_watsup"
* Loop through each indicator
foreach indicator of local indicators {
use "${do2}Effectiveness.dta", clear
keep countryname countrycode continent region region_code year_acled year_ipums indicator_vector value_norm
keep if indicator_vector == "`indicator'"
* Sort the data by the variable density_10
sort value_norm
* Create the decile variable
xtile decile = value_norm, nq(10)
* Convert numeric decile values to string labels
label define decile 1 "Decile 1" 2 "Decile 2" 3 "Decile 3" 4 "Decile 4" 5 "Decile 5" 6 "Decile 6" 7 "Decile 7" 8 "Decile 8" 9 "Decile 9" 10 "Decile 10"
label values decile decile
keep if countryname=="Armenia" | countryname=="Benin" | countryname=="Brazil" | countryname=="Laos" | countryname=="Costa Rica" | countryname=="Haiti"| countryname=="Honduras" | countryname=="Mali" | countryname=="Mozambique"
*Brazil
replace region="Rondonia" if (region=="Rondônia" & countryname=="Brazil")
replace region="Para" if (region=="Pará" & countryname=="Brazil")
replace region="Amapa" if (region=="Amapá" & countryname=="Brazil")
replace region="Maranhao" if (region=="Maranhão" & countryname=="Brazil")
replace region="Piaui" if (region=="Piauí" & countryname=="Brazil")
replace region="Espiritu Santo" if (region=="Espírito Santo" & countryname=="Brazil")
replace region="Parana" if (region=="Paraná" & countryname=="Brazil")
replace region="Goias" if (region=="Goiás" & countryname=="Brazil")
*Mozambique 
replace region="Cidade De Maputo" if (region=="Maputo city" & countryname=="Mozambique")
replace region="Maputo" if (region=="Maputo province" & countryname=="Mozambique")
*Country code
gen isoc="geo1_am2001" if countryname=="Armenia"
replace isoc="geo1_bj2013" if countryname=="Benin"
replace isoc="geo1_br2010" if countryname=="Brazil"
replace isoc="geo1_cr2011" if countryname=="Costa Rica"
replace isoc="geo1_hn2001" if countryname=="Honduras"
replace isoc="geo1_ht2003" if countryname=="Haiti"
replace isoc="geo1_la2005" if countryname=="Laos"
replace isoc="geo1_ml2009" if countryname=="Mali"
replace isoc="geo1_mz2007" if countryname=="Mozambique"
*Exporting results
tempfile temp_eff_map_`indicator'
save "`temp_eff_map_`indicator''", replace
}
clear 
foreach indicator of local indicators {
    ap using "`temp_eff_map_`indicator''"
}
export excel using "${do2}effectiveness_maps.xlsx", firstrow (variables) replace
