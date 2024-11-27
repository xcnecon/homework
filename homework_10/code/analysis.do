cd "$data"
use "hhprice_train.dta", clear

// Generate dep var
gen target = log(price)
label variable target "Log Price"
// Drop unused variables
drop postcode price1000 x 

// sum stats
estpost sum target rooms bathroom car landsize buildingarea yearbuilt latitud longitud prop_count date
est sto table
cd "$root"
esttab table using sum_stats.txt , cells("count min max mean sd") nomtitle nonumber md replace label

// Create dummy variables for suburb, region, council, and seller, with drops for low-frequency categories
tabulate suburb, generate(suburb_)
drop suburb
foreach var of varlist suburb_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}
drop suburb_1 suburb_3 suburb_8 suburb_10 suburb_19 suburb_48 suburb_51 suburb_81 suburb_89 suburb_102 suburb_112 suburb_124 suburb_128 suburb_141 suburb_142 suburb_152 suburb_168 suburb_186 suburb_208 suburb_219 suburb_238 suburb_258 suburb_287 suburb_296 suburb_307

tabulate region_code, generate(region_)
drop region_code
foreach var of varlist region_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}
drop region_1

tabulate council_code, generate(council_)
drop council_code
foreach var of varlist council_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}
drop council_1 council_14 council_17 council_18 council_25

tabulate sellerg2, generate(seller_)
drop sellerg2
foreach var of varlist seller_* {
    quietly count if `var' == 1
    if r(N) < 20 drop `var'
}
drop seller_28 seller_29 seller_36 seller_53 seller_60 seller_97 seller_138 seller_139 seller_163 seller_169 seller_192 seller_207

// Feature engineering
gen distance_2 = distance^2
gen rooms_2 = rooms^2
gen bathroom_2 = bathroom^2
gen l_landsize = log(landsize)
gen l_buildingarea = log(buildingarea)
gen latitud_2 = latitud^2
gen longitud_2 = longitud^2

// Create a temporary file to store model statistics
tempfile results
postfile results N r2 adjr2 rmse aic bic kfold1 kfold2 using `results'

// Define a helper program to store key statistics for each model
capture program drop store_model_stats
program define store_model_stats
    cv_kfold, k(5) reps(5)
    scalar kfold1 = real(r(mmsqr))  // Convert to numeric
    cv_kfold, k(10) reps(5)
    scalar kfold2 = real(r(mmsqr))  // Convert to numeric
    estat ic
    scalar aic = r(S)[1,5]
    scalar bic = r(S)[1,6]
    post results (e(N)) (e(r2)) (e(r2_a)) (e(rmse)) (aic) (bic) (kfold1) (kfold2)
end

// Model 1
reg target council_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize rooms car i.type_h)
store_model_stats

// Model 2
reg target council_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize l_buildingarea rooms car i.type_h) l_buildingarea yearbuilt 
store_model_stats

// Model 3
reg target suburb_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize rooms car i.type_h)
store_model_stats

// Model 4
reg target council* suburb_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize rooms car i.type_h)
store_model_stats

// Fill missing values
replace yearbuilt = 1963 if missing(yearbuilt)
replace l_buildingarea = 4.93 if missing(l_buildingarea)

// Model 5
reg target suburb_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize l_buildingarea rooms car i.type_h) l_buildingarea yearbuilt 
store_model_stats

// Model 6
reg target council* suburb_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize l_buildingarea rooms car i.type_h) l_buildingarea yearbuilt 
store_model_stats

// Model 7
reg target council* suburb_* region* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize latitud latitud_2 longitud longitud_2 prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize l_buildingarea rooms car i.type_h) l_buildingarea yearbuilt 
store_model_stats

// Model 8
reg target suburb_* seller_* i.type_h distance distance_2 rooms rooms_2 bathroom bathroom_2 car l_landsize prop_count date c.rooms#c.bathroom c.distance#c.(l_landsize l_buildingarea rooms car i.type_h) l_buildingarea yearbuilt
store_model_stats

// Close postfile and display results
postclose results
use `results', clear
list // to display the summary of results
