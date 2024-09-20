# Content
This repository contains data, code, and results for Homework 2. The final tidy data is in the workfile.dta in /data/tidy_data.  

# Report
## Three variables I chose:  
1. External debt (current dollars)
2. Current account balance (current dollars)
3. Nominal GDP growth rate.  

## Answers to questions
Number of countries in my data table (after cleaning): 219  
Number of years in my data table (after cleaning): 64  
The country with the highest external debt in 2000: Brazil  
The country with the lowest external debt in 2000: Kosovo  
The country with the highest current account balance (largest trade surplus) in 2000: Japan  
The country with the lowest current account balance (largest trade deficit) in 2000: United States  
The country with the highest nominal GDP growth rate in 2000: Timor-Leste  
The country with the lowest nominal GDP growth rate in 2000: Solomon Islands  

## What did I do to obtain the data:  
1. Data collection and preliminary cleaning: I manually downloaded data for the three variables from the World Bank website. The three CSV files contained some descriptive text above the data tables, which I deleted. When I tried to import the three CSV files into Stata, Stata created new variable names instead of using the first-row names in the CSV files because those names were capitalized and contained pure numbers. I lowercased the variable names and added 'year' before all the numbers.  
2. Data cleaning: I reshaped the three data tables from wide to long format and then merged them into one workfile. After noticing missing values, I deleted the rows that were missing all three variables I had selected. I also observed that some entities in the data table were regional aggregates rather than countries, so I created a country flag using information from a CSV file that accompanied the three data tables and described all the entities. By merging the country flag into the workfile, I deleted all non-country entities.  

## Difficulties encountered:  
Creating the country flag was somewhat challenging. I had to refer to the background information provided by the World Bank, as there was no existing variable that indicated whether an entity in the data tables was a country. I noticed that all the non-country entities had missing values for their region variable, and I used this feature to create the country flag.  