// this file is for analysing the wms-management-survey dataset
cd "$data"
use "wms_da_textbook.dta", clear
// pick country United States
keep if country == "United States"
// create histogram for management socre
sum management
hist management, width(0.25) percent xtitle("Management score")
cd "$result"
graph export "management_score.png",replace
// create histogram for employment size
sum emp_firm
hist emp_firm, width(500) percent xtitle("Firm size (employment)")
graph export "management_size.png", replace
// create histogram for natural log of number of employment
gen log_emp = ln(emp_firm)
sum log_emp
hist log_emp, width(0.25) percent xtitle("Firm size (ln(employment))")
graph export "management_logsize.png", replace
