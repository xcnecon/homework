cd "$data"
use "stock_prices.dta", clear       // Load stock prices dataset and clear existing data
tsset ym                            // Set time variable for monthly data
label variable ym "Date(month)"      // Label date variable

keep ym disney sp500                // Keep only year-month, Disney, and SP500 variables
order ym                            // Ensure ym is first column

cd "$results"                       // Set directory for results

// Plot Disney stock price over time
line disney ym, xtitle("Date(month)") ytitle("Disney stock price (US dollars)") title("(a) Disney")
graph save chart1.gph, replace      // Save Disney plot

// Plot SP500 index price over time
line sp500 ym, xtitle("Date(month)") ytitle("SP500 index price (US dollars)") title("(b) SP500")
graph save chart2.gph, replace      // Save SP500 plot

graph combine chart1.gph chart2.gph, cols(2)   // Combine plots into one graph
graph export "monthly_price_chart.png", replace // Export combined plot as PNG
erase chart1.gph                              // Delete individual plots
erase chart2.gph

// Calculate annualized return for Disney and SP500
display (149.44 / 32.07) ^ (1/11) -1 // Disney annualized return
display (3662.45 / 1132.99) ^ (1/11) -1 // SP500 annualized return

// Run Phillips-Perron test on stock prices
pperron disney                       
pperron sp500                        

// Calculate monthly returns for Disney and SP500
gen r_disney = disney / l.disney - 1 // Disney monthly return
gen r_sp = sp500 / l.sp500 - 1       // SP500 monthly return

// Plot Disney monthly return over time
line r_disney ym, xtitle("Date(month)") ytitle("Disney monthly return (%)") title("(a) Disney")
graph save chart1.gph, replace       // Save Disney return plot

// Plot SP500 monthly return over time
line r_sp ym, xtitle("Date(month)") ytitle("SP500 monthly return (%)") title("(b) SP500")
graph save chart2.gph, replace       // Save SP500 return plot

graph combine chart1.gph chart2.gph, cols(2) ycommon // Combine return plots with shared y-axis
graph export "monthly_return_chart.png", replace    // Export combined return plot as PNG
erase chart1.gph                                    // Delete individual return plots
erase chart2.gph

// Label variables
label variable r_disney "Monthly returns on Disney (%)"
label variable r_sp "Monthly returns on SP500 (%)"

// Summary statistics for returns
estpost sum r_disney r_sp            // Post summary stats for Disney and SP500 returns
est sto return_table                 // Store results as return_table
esttab return_table using return_table.txt, cells("min max mean sd count") nomtitle nonumber md replace label // Export table

// Phillips-Perron test on monthly returns
pperron r_disney                     
pperron r_sp                         

// Regression of Disney returns on SP500 returns with robust std. errors
reg r_disney r_sp, robust
estimates store m1
esttab m1 using reg_table_1.txt, b(2) se(2) star(* 0.05 ** 0.01) r2 ar2 nonumber replace note("Robust std. err. in parentheses") noline md mtitle("Disney Return") label

// Scatter plot with fitted line and 45-degree reference line
gen temp = r_sp
label variable temp "45 degree line"
twoway (scatter r_disney r_sp)(lfit r_disney r_sp)(line temp r_sp), legend(position(4) ring(0) size(small))
graph export "visual1.png", replace

// Line plots of returns over time for two periods
twoway (line r_disney ym)(line r_sp ym), xtitle("Date(month)") ytitle("monthly return (%)") title("(a) The entire time series, 2010-2020") legend(position(11) ring(0) size(small))
graph save chart3.gph, replace

twoway (line r_disney ym)(line r_sp ym) if ym >= tm(2018m1), xtitle("Date(month)") ytitle("monthly return (%)") title("(a) The entire time series, 2010-2020") legend(position(11) ring(0) size(small))
graph save chart4.gph, replace

graph combine chart3.gph chart4.gph, cols(2)   // Combine line plots into one graph
graph export "visual2.png", replace // Export combined plot as PNG
erase chart3.gph                    // Delete individual plots
erase chart4.gph

gen l_disney = log(disney)
gen d_l_disney = d.l_disney
gen l_sp = log(sp500)
gen d_l_sp = d.l_sp
label variable d_l_disney "Monthly log change for Disney"
label variable d_l_sp "Monthly log change for SP500"

reg d_l_disney d_l_sp, robust
estimates store m2
esttab m1 m2 using reg_table_2.txt, b(2) se(2) star(* 0.05 ** 0.01) r2 ar2 nonumber replace note("Robust std. err. in parentheses") noline md mtitle("Monthly pct chaneg" "Monthly log change") label
