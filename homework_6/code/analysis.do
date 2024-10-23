// import data
cd "$data"
use "wms_da_textbook.dta", clear

// choose country Singapore
keep if country == "Singapore"
drop aa*

// rename lables
label variable emp_firm "Number of Employees"
label variable management "management score"

// ols regression
reg emp_firm management, robust
est store m1
cd "$results"
esttab m1 using ols.txt, replace nonumbers

// ols plot
predict y_hat
twoway(scatter emp_firm management, msize(tiny))(lfitci emp_firm management, fcolor(%20))
graph export "ols.png", replace

// lpoly plot
lpoly emp_firm management, ci msize(tiny)
graph export "lpoly.png", replace
