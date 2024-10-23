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
esttab m1 using ols.txt, b(3) ci star(* 0.10 ** 0.05 *** 0.01) r2 replace nonumbers label wide note("") md noline

// ols plot
twoway(scatter emp_firm management, msize(tiny))(lfitci emp_firm management, fcolor(%20)), title("Simple Linear Estimates")
graph export "ols.png", replace

// lpoly plot
lpoly emp_firm management, ci msize(tiny) title("Lpoly Plot")
graph export "lpoly.png", replace

// spline log-level regression
mkspline m1 2 m2 4 m3= management
gen l_emp = log(emp_firm)
reg l_emp m1-m3
est store m2
esttab m2 using nonlinear.txt, b(3) ci star(* 0.10 ** 0.05 *** 0.01) r2 replace nonumbers label wide note("") md noline

// plot spline log-level regression
predict y_hat
gen y_hat_exp = exp(y_hat)
sort management
twoway (scatter emp_firm management, msize(tiny)) (line y_hat_exp management), title("Nonlinear Estimates")
graph export "nonlinear.png", replace
