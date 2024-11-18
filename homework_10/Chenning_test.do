** CHenning
 
use "C:/Users/Fernando/Documents/GitHub/riosavila/rm-data/hhprice_train.dta", clear
// Generate dep var
gen target = log(price)
label variable target "Log Price"
// Drop unused variables
drop postcode price1000 x 

// Create dummy variables for suburb, region, council, and seller, with drops for low-frequency categories
tabulate suburb, generate(suburb_)
*drop suburb
foreach var of varlist suburb_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}

tabulate region_code, generate(region_)
*drop region_code
foreach var of varlist region_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}
drop region_1

tabulate council_code, generate(council_)
*drop council_code
foreach var of varlist council_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}
drop council_1 council_14 council_17 council_18 council_25

tabulate sellerg2, generate(seller_)
*drop sellerg2
foreach var of varlist seller_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}

drop seller_28 seller_29 seller_36 seller_53 seller_60 seller_97 seller_138 seller_139 seller_163 seller_169 seller_192 seller_207

ren seller_* sseller_*
foreach i of varlist sseller_* {
    sum sellerg2 if `i'==1, meanonly
    local ll = r(mean)
    gen seller_`ll' = sellerg2==`ll'
}
drop sseller_*


ren council_* scouncil_*
ren scouncil_code council_code
foreach i of varlist scouncil_* {
    sum council_code if `i'==1, meanonly
    local ll = r(mean)
    gen council_`ll' = council_code==`ll'
}
drop scouncil_*

ren suburb_* ssuburb_*
*ren scouncil_code council_code
foreach i of varlist ssuburb_* {
    sum suburb if `i'==1, meanonly
    local ll = r(mean)
    gen suburb_`ll' = suburb==`ll'
}
drop ssuburb_*

// Feature engineering
gen distance_2 = distance^2
gen rooms_2 = rooms^2
gen bathroom_2 = bathroom^2
gen l_landsize = log(landsize)
gen l_buildingarea = log(buildingarea)
gen latitud_2 = latitud^2
gen longitud_2 = longitud^2


// Fill missing values
replace yearbuilt = 1963 if missing(yearbuilt)
replace l_buildingarea = 4.93 if missing(l_buildingarea)

// Model 6
reg target council* suburb_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize l_buildingarea rooms car i.type_h) l_buildingarea yearbuilt 

est sto m1 


*** Predict
use "C:/Users/Fernando/Documents/GitHub/riosavila/rm-data/hhprice_train.dta", clear
levelsof council_code, local(lcn1)
levelsof sellerg2    , local(lcn2)
levelsof suburb      , local(lcn3)

use "C:/Users/Fernando/Documents/GitHub/riosavila/rm-data/hhprice_test.dta", clear

sum latitud
replace latitud = r(mean) if latitud==.
sum longitud
replace longitud= r(mean) if longitud==.
gen target = log(price)
label variable target "Log Price"
// Drop unused variables
drop postcode price1000 x 

// Create dummy variables for suburb, region, council, and seller, with drops for low-frequency categories
 *drop suburb

 

tabulate region_code, generate(region_)
*drop region_code
 
drop region_1

foreach i of local lcn1 {
      gen council_`i' = council_code==`i'
}

foreach i of local lcn2 {
      gen seller_`i' = sellerg2==`i'
}

foreach i of local lcn3 {
      gen suburb_`i' = suburb==`i'

} 
// Feature engineering
gen distance_2 = distance^2
gen rooms_2 = rooms^2
gen bathroom_2 = bathroom^2
gen l_landsize = log(landsize)
gen l_buildingarea = log(buildingarea)
gen latitud_2 = latitud^2
gen longitud_2 = longitud^2


// Fill missing values
replace yearbuilt = 1963 if missing(yearbuilt)
replace l_buildingarea = 4.93 if missing(l_buildingarea)

predict target_hat


gen mse = (target-target_hat)^2
total mse


