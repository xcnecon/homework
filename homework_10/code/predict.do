// get the model from the training data
cd "$data"
use "hhprice_train.dta", clear

// gen target
gen target = log(price)

// create dummies
tabulate suburb, generate(suburb_)
foreach var of varlist suburb_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}

tabulate council_code, generate(council_)
foreach var of varlist council_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}

tabulate sellerg2, generate(seller_)
drop sellerg2
foreach var of varlist seller_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}

drop suburb_1 suburb_3 suburb_8 suburb_10 suburb_19 suburb_48 suburb_51 suburb_81 suburb_89 suburb_102 suburb_112 suburb_124 suburb_128 suburb_141 suburb_142 suburb_152 suburb_168 suburb_186 suburb_208 suburb_219 suburb_238 suburb_258 suburb_287 suburb_296 suburb_307
drop council_1 council_14 council_17 council_18 council_25
drop seller_28 seller_29 seller_36 seller_53 seller_60 seller_97 seller_138 seller_139 seller_163 seller_169 seller_192 seller_207

// manipulate continous variables
gen distance_2 = distance^2
gen rooms_2 = rooms^2
gen bathroom_2 = bathroom^2
gen l_landsize = log(landsize)
gen l_buildingarea = log(buildingarea)
gen latitud_2 = latitud^2
gen longitud_2 = longitud^2

// fill missing values
replace yearbuilt = 1963 if missing(yearbuilt)
replace l_buildingarea = 4.93 if missing(l_buildingarea)

// get model
reg target council* suburb_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize l_buildingarea rooms car i.type_h) l_buildingarea yearbuilt 
est sto model

// import testing sample
cd "$data"
use "hhprice_test.dta", clear
est restore model
predict y_hat