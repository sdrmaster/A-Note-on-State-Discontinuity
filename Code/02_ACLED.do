clear all
import delimited "${di1}ACLED_2023-01-01-2023-11-07.csv", clear

* n is 1 if the protest is not a peaceful protest (henceforth it is a violent one)
gen n=1 if sub_event_type!="Peaceful protest"
replace n=0 if n==.

* Malawi and Sierra Leone - collapse at admin2 level
replace admin1 = admin2 if country=="Malawi" | country=="Sierra Leone"

* Collapse at level of day first (there might be different protests in the same region in one day)
collapse (sum) fatalities n, by(year iso region country admin1 timestamp)

* We would say that in a region there has been at least 1 protest each day
*replace n=1 if n!=0
collapse (sum) n fatalities, by(year iso region country admin1)

rename admin1 admin1_original
gen admin1 = strlower(region)

rename n violence
gen source = "ACLED"

save "${do2}ACLED_2023.dta", replace
