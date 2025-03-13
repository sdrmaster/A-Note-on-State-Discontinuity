//IPUMS Database
clear all
*Generate Labels
import excel "${do1}ipums_state_density_countries_final.xlsx", sheet("IPUMS") firstrow clear
*import delimited "${data}/ipums_state_density_countries_final.csv", delimiter("", collapse) clear 
gen id=1
collapse (mean) id, by(countryname countrycode continent region region_lab region_code level)
save "${do2}labels_ipums.dta", replace


//ACLED database
*admin level 1
use "${do2}ACLED_2023.dta", clear
*Convert to lowercase
rename country countryname
gen lowercase_string = lower(admin1_original)
*Remove special characters and create a new variable
gen region2= ustrlower( ustrregexra( ustrnormalize( lowercase_string, "nfd" ) , "\p{Mark}", "" )  )
*Manually replace names
replace region2="buenos aires province" if region2=="buenos aires" & countryname=="Argentina"
replace region2="capital federal" if region2=="ciudad autonoma de buenos aires" & countryname=="Argentina"
replace region2="del chaco" if region2=="chaco" & countryname=="Argentina"
replace region2="del chubut" if region2=="chubut" & countryname=="Argentina"
replace region2="del neuquen" if region2=="neuquen" & countryname=="Argentina"
*Minsk city does not appear in IPUMS. We grouped minsk and minsk city (Belarus)
replace region2="minsk" if region2=="minsk city" & countryname=="Belarus"
*Banteay meanchey, kampong cham, kampong thom, kampot, kep, kratie, odar meanchey, pailin, preah vihear, prey veng, ratanak kiri, sihanoukville, stung treng, svay rieng, takeo do not appear in the ACLED database (Cambodia)
replace region2="federal district" if region2=="distrito federal" | region2=="distrito capital"
replace region2="bogota" if region2=="bogota, d.c." & countryname=="Colombia"
*Amazonas, Guaviare, Vaupés, Vichada y Guainía are grouped in the Ipums database (Colombia)
*Vaupes is not available in ACLED (Colombia)
replace region2="amazonas, guaviare, vaupes, vichada, guania" if (region2=="amazonas"  | region2=="guaviare" | region2=="vichada"  | region2=="guainia") & countryname=="Colombia"
replace region2="san andres" if region2=="san andres y providencia" & countryname=="Colombia"
replace region2="valle" if region2=="valle del cauca" & countryname=="Colombia"
*Baoruco, san jose de ocoa, san juan, sanchez ramirez do not appear in the ACLED database (Costa Rica)
*Canar y el piedrero are grouped in the IPUMS database (Ecuador)
*Guayas and Galapagos are grouped in the IPUMS database (Ecuador)
*Las golondrinas e Imbabura are grouped in the IPUMS database (Ecuador)
*Manga del cura, Pastaza, Zamora Chinchipe  do not appear in ACLED (Ecuador)
replace region2="canar, el piedrero [disputed zone]" if region2=="canar" & countryname=="Ecuador"
replace region2="guayas and galapagos" if (region2=="galapagos"  | region2=="guayas") & countryname=="Ecuador"
replace region2="las golondrinas [disputed zone], imbabura" if region2=="imbabura" & countryname=="Ecuador"
replace region2="brong ahafo" if region2=="ahafo" & countryname=="Ghana"
replace region2="centre (central)" if region2=="centre" & countryname=="Haiti"
replace region2="grand'anse" if region2=="grande-anse" & countryname=="Haiti"
replace region2="nord (north)" if region2=="nord" & countryname=="Haiti"
replace region2="nord'est (north east)" if region2=="nord-est" & countryname=="Haiti"
replace region2="nord'ouest (north west)" if region2=="nord-ouest" & countryname=="Haiti"
replace region2="ouest (west)" if region2=="ouest" & countryname=="Haiti"
replace region2="sud (south)" if region2=="sud" & countryname=="Haiti"
replace region2="sud'est (south east)" if region2=="sud-est" & countryname=="Haiti"
replace region2="l'artibonite" if region2=="artibonite" & countryname=="Haiti"
*l'artibonite does not appear in the ACLED database (Haiti)
replace region2="islas de la bahia" if region2=="bay islands" & countryname=="Honduras"
*alborz does not appear in IPUMS (Iran) 
replace region2="ardebil" if region2=="ardabil" & countryname=="Iran"
replace region2="chaharmahal and bakhtiyari" if region2=="chaharmahal and bakhtiari" & countryname=="Iran"
replace region2="east azarbayejan" if region2=="east azerbaijan" & countryname=="Iran"
*esfahan does not appear in ACLED database
replace region2="hamedan" if region2=="hamadan" & countryname=="Iran"
*isfahan does not appear in ACLED database
replace region2="kohgiluyeh and boyerahmad" if region2=="kohgiluyeh and boyer-ahmad" & countryname=="Iran"
replace region2="kordestan" if region2=="kurdistan" & countryname=="Iran"
replace region2="west azarbayejan" if region2=="west azerbaijan" & countryname=="Iran"
replace region2="al-anbar" if region2=="al anbar" & countryname=="Iraq"
replace region2="al-basrah" if region2=="al basrah" & countryname=="Iraq"
replace region2="al-muthanna" if region2=="al muthanna" & countryname=="Iraq"
replace region2="al-najaf" if region2=="al najaf" & countryname=="Iraq"
replace region2="al-qadisiya" if region2=="al qadissiya" & countryname=="Iraq"
replace region2="babylon" if region2=="babil" & countryname=="Iraq"
replace region2="diala" if region2=="diyala" & countryname=="Iraq"
replace region2="kerbela" if region2=="kerbala" & countryname=="Iraq"
replace region2="nineveh" if region2=="ninewa" & countryname=="Iraq"
replace region2="salah al-deen" if region2=="salah al din" & countryname=="Iraq"
replace region2="thi-qar" if region2=="thi qar" & countryname=="Iraq"
replace region2="wasit" if region2=="wassit" & countryname=="Iraq"
*al-qadisiya and al-tameem do not appear in the ACLED dataset (Iraq)
replace region2="central province" if (region2=="nyandarua" | region2=="nyeri" | region2=="kirinyaga" | region2=="muranga" | region2=="kiambu") & countryname=="Kenya"
replace region2="coast province" if (region2=="mombasa" | region2=="kwale" | region2=="kilifi" | region2=="tana river" | region2=="lamu" | region2=="taita taveta") & countryname=="Kenya"
replace region2="eastern province" if (region2=="marsabit" | region2=="isiolo" | region2=="meru" | region2=="tharaka-nithi" | region2=="embu" | region2=="kitui" | region2=="machakos" | region2=="makueni") & countryname=="Kenya"
replace region2="north rift valley province" if (region2=="elgeyo marakwet" | region2=="nandi" | region2=="trans nzoia" | region2=="turkana" | region2=="uasin gishu" | region2=="west pokot") & countryname=="Kenya"
replace region2="south rift valley province" if (region2=="samburu" | region2=="baringo" | region2=="laikipia" | region2=="nakuru" | region2=="narok" | region2=="kajiado" | region2=="kericho" | region2=="bomet") & countryname=="Kenya"
replace region2="north-eastern province" if (region2=="garissa" | region2=="mandera" | region2=="wajir") & countryname=="Kenya"
replace region2="nyanza province" if (region2=="siaya" | region2=="kisumu" | region2=="homa bay" | region2=="migori" | region2=="kisii" | region2=="nyamira") & countryname=="Kenya"
replace region2="western province" if (region2=="kakamega" | region2=="vihiga" | region2=="bungoma" | region2=="busia") & countryname=="Kenya"
* For Laos we only observe a datapoint in ACLED: Vientiane Prefecture
replace region2="vientiane" if (region2=="vientiane prefecture") & countryname=="Laos"
*Berea, butha buthe, mohale's hoek, mokhotlong, quthing, thaba tseka in Lesotho are not presented in the ACLED database
*Bomi, Bong, Gbarpolu, Grand Kru, Margibi, River Gee, Rivercess do not appear in ACLED database (Liberia)
*Menaka does not appear in IPUMS (Mali).
replace region2="distrito federal" if region2=="ciudad de mexico" & countryname=="Mexico" 
replace region2="maputo province" if region2=="maputo" & countryname=="Mozambique"
*bheri, dhawalagiri, janakpur, mahakali, mechi, narayani, rapti, sagarmatha, seti do not appear in ACLED database (Nepal)
*sudurpashchim do not appear in IPUMS (Nepal)
replace region2="koshi" if region2=="province 1" & countryname=="Nepal"
replace region2="janakpur" if region2=="madhesh" & countryname=="Nepal"
*carazo, rio san juan do not appear in ACLED database (Nicaragua)
replace region2="atlantico norte" if region2=="costa caribe norte" & countryname=="Nicaragua"
replace region2="atlantico sur" if region2=="costa caribe sur" & countryname=="Nicaragua"
* boqueron, alto paraguay, chaco, nueva asuncion are grouped in IPUMS (Paraguay)
replace region2="boqueron, alto paraguay, chaco, nueva asuncion" if (region2=="boqueron" | region2=="alto paraguay") & countryname=="Paraguay"
*chaco and nueva asuncion do not appear in ACLED dataset (Paraguay)
* We have grouped the rwanda regions in the IPUMS dataset
replace region2="kigali ville" if region2=="kigali city" & countryname=="Rwanda"
*kedougou, kaffrine and sedhiou are not available in IPUMS dataset (Senegal)
  replace region2="saint-louis" if region2=="saint louis" & countryname=="Senegal"
  *Falaba,  karene do not appear in IPUMS dataset (Sierra Leone)
  *Moyamba and koinadugu do not appear in ACLED dataset (Sierra Leone)
replace region2="western rural" if region2=="western area rural" & countryname=="Sierra Leone"
replace region2="western urban" if region2=="western area urban" & countryname=="Sierra Leone"
*abyei, central darfur, east darfur, and west kordofan do not appear in IPUMS (Sudan)
replace region2="al gezira" if region2=="al jazirah" & countryname=="Sudan"
replace region2="al gedarif" if region2=="gedaref" & countryname=="Sudan"
replace region2="sinnar" if region2=="sennar" & countryname=="Sudan"
replace region2="nahr el nil" if region2=="river nile" & countryname=="Sudan"
*Iringa, kagera, kilimanjaro, mtwara, njombe, pemba north, pemba south, ruvuma, shinyanga, simiyu, singida, zanzibar north, zanzibar south and zanzibar west do not appear in ACLED dataset (Tanzania)
*Angthong, chachoengsao, chainat, chaiyaphum, chanthaburi, chon buri, chumphon, kalasin, kamphaeng phet, kanchanaburi, krabi, lamphun, loei, lop buri,nakhon nayok, nakhon si thammarat, nan, nong khai, petchabun, petchaburi, phang nga, phatthalung, phayao, phichit,prachin buri, prachuap khiri khan, ranong, ratchaburi, rayong, sakon nakhon, saraburi, satun, si sa ket, sing buri, sukhothai, suphan buri, surat thani, surin, trang, trat, uthai thani, uttaradit, yala, yasothon do not appear in ACLED dataset (Thailand)
*Bueng kan does not appear in IPUMS (Thailand)
replace region2="bangkok metropolis" if region2=="bangkok" & countryname=="Thailand"
replace region2="ayutthaya" if region2=="phra nakhon si ayutthaya" & countryname=="Thailand"
*cerro largo, durazno, flores, rivera, rocha, río negro, san jose, soriano, tacuarembó, treinta y tres do not appear in ACLED (Uruguay)
*centrale, lome, plateaux do not appear in ACLED dataset (Togo)
replace region2="nueva esparta, federal dependencies" if region2=="nueva esparta" & countryname=="Venezuela"
*vargas does not appear in ACLED database (Venezuela)
*Muchinga does not appear in IPUMS (Zambia)
*Western does not appear in ACLED (Zambia)
collapse (sum) fatalities violence, by(countryname region2)
*save dataset
save "${do2}ACLED_adminlevel1.dta", replace
//Import IPUMS data

import excel "${do1}ipums_state_density_countries_final.xlsx", sheet("IPUMS") firstrow clear


 
* Convert to lowercase
gen lowercase_string = lower(region)
*Remove special characters and create a new variable
gen region2 = ustrlower( ustrregexra( ustrnormalize( lowercase_string, "nfd" ) , "\p{Mark}", "" )  )
gen id=1
collapse (mean) id, by(countryname region region2)
merge 1:1 countryname region2 using  "${do2}ACLED_adminlevel1.dta"

keep if _merge==1 | _merge==3
*replace  violence=0 if violence==.
*replace  fatalities=0 if fatalities==.
drop _merge id
gen year=2023
*List of variables to exclude from renaming
local exclude_vars countryname region2 region year

*Add "_new" extension to all variables except the excluded ones
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
*Reshape dataset to obtain the desired format
reshape long ind_, i(countryname year region region2) j(variable) string

*rename some variables
rename variable indicator_original
rename ind_ value_original

*Generate some definitions
gen definition_original="The number of reported fatalities arising from an event. When there are conflicting reports, the most conservative estimate is recorded." if indicator_original=="fatalities"
replace definition_original="ACLED defines `Violence against civilians' as violent events where an organized armed group inflicts violence upon unarmed non-combatants. By definition, civilians are unarmed and cannot engage in political violence" if indicator_original=="violence"

*Generate some additional variables
gen indicator_vector="no_violence" if indicator_original=="violence"
gen new_definition_vector="number of days in the year w/o episodes of violence"   if indicator_original=="violence"
gen value_vector= 365-value_original  if indicator_original=="violence"
replace value_vector = 0 if value_original>365
replace value_vector = 365 if value_original==.
gen source="ACLED"
gen unit="Region"
gen domain="Security"
gen sample=""


*add some labels
merge m:1 countryname region using "${do2}labels_ipums.dta"
keep if _merge==3
drop id _merge region2

*order dataset
order countryname countrycode sample continent year region region_lab region_code level domain indicator_original definition_original unit value_original indicator_vector new_definition_vector value_vector source

keep  if indicator_original=="violence"
*save merged database
save "${do2}ACLED_merged_final.dta", replace




