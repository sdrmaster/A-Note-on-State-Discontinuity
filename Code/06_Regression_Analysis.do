clear all
*Density
*Importing data
import excel "${do1}IPUMS_controls_countries.xlsx", firstrow clear
merge 1:1 region countryname using "${do2}Density"
keep if _merge==3
drop _merge

gen Area=areamollwgeo1/1000
gen Population=(popdensgeo1/1000)^2

rename foreign_perc Foreign
rename urbanh_perc Urban 
rename indig_perc Indigenous

*Table A4 (from the Appendix)
asdoc pwcorr Area Foreign Indigenous Population Urban, sig save(${annex_tab}tabA4_pairw_correl.doc) replace 

*Fixed effects models (simplified version)
encode countryname, generate(country_numeric)
xtset country_numeric
eststo clear
eststo: xtreg density_5 Area Foreign Indigenous Population Urban, fe 
eststo: xtreg density_10 Area Foreign Indigenous Population Urban, fe 
eststo: xtreg density_20 Area Foreign Indigenous Population Urban, fe 

*Pooled models
eststo: reg density_5 Area Foreign Indigenous Population Urban
eststo: reg density_10 Area Foreign Indigenous Population Urban
eststo: reg density_20 Area Foreign Indigenous Population Urban
*Table 5
esttab using "${tab}tab5_reg_dens_fe_pooled.tex", noconstant replace title("Correlates to State's Density, different values of theta") compress r2

*Effectiveness
*Importing data
import excel "${do1}IPUMS_controls_countries.xlsx", firstrow clear
merge 1:1 region countryname using "${do2}Normalized_Values"
keep if _merge==3
drop _merge

gen Area=areamollwgeo1/1000
gen Population=(popdensgeo1/1000)^2

rename foreign_perc Foreign
rename urbanh_perc Urban 
rename indig_perc Indigenous

*Fixed effects models (simplified version)
encode countryname, generate(country_numeric)
xtset country_numeric
eststo clear
eststo: xtreg basic_services_norm Area Foreign Indigenous Population Urban, fe 
eststo: xtreg literate_perc_norm Area Foreign Indigenous Population Urban, fe 
eststo: xtreg child_surv_norm Area Foreign Indigenous Population Urban, fe 
eststo: xtreg no_violence_norm Area Foreign Indigenous Population Urban, fe 

*Pooled models
eststo: reg basic_services_norm Area Foreign Indigenous Population Urban
eststo: reg literate_perc_norm Area Foreign Indigenous Population Urban
eststo: reg child_surv_norm Area Foreign Indigenous Population Urban
eststo: reg no_violence_norm Area Foreign Indigenous Population Urban
*Table 6
esttab using "${tab}tab6_reg_effect_fe_pooled.tex", noconstant replace title("Correlates of State's Effectiveness, theta=1") compress r2