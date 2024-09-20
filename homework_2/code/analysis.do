// set directories
global root "/Users/chenning/Documents/GitHub/homework_2"
global data "$root/data"
global raw "$data/raw_data"
global tidy "$data/tidy_data"

// import workfile for analysis
cd $tidy
use "workfile.dta", clear

// to know how many countires are years are thre in my data
ssc install unique
unique country //219 countries
unique year //64 years

// to know which countries are ranked highest and lowest in each of the three indicators in the year 2000
// external debt
sum external_debt if (year == 2000)
scalar max_ed = r(max)
scalar min_ed = r(min)
list country if (external_debt == max_ed) & (year == 2000) 
// the country with highest external debt in 2000 is Brizil
list country if (external_debt == min_ed) & (year == 2000) 
// the country with lowest external debt in 2000 is Kosovo

// current account balance
sum current_account_balance if (year == 2000)
scalar max_ca = r(max)
scalar min_ca = r(min)
list country if (current_account_balance == max_ca) & (year == 2000) 
// the country with highest current account balance in 2000 is Japan
list country if (current_account_balance == min_ca) & (year == 2000) 
// the country with lowest current account balance in 2000 is United States

// nominal GDP growth
sum nominal_gdp_growth if (year == 2000)
scalar max_ngg = r(max)
scalar min_ngg = r(min)
list country if (nominal_gdp_growth == max_ngg) & (year == 2000) 
// the country with highest current account balance in 2000 is Timor-Leste
list country if (nominal_gdp_growth == min_ngg) & (year == 2000) 
// the country with lowest current account balance in 2000 is Solomon Islands
