// this file is to produce a different table showing the extent of home team advantage for the football dataset

// import data and drop unwanted columns
cd "$data"
use "epl_teams_games.dta", clear
// keep 2016 and 2017 seasons
keep if season == 2016 | season == 2017
// diff = home team goals - away team goals
gen diff = cond(home==1, goals-goals_opponent, goals_opponent-goals)
// summarize diff
sum diff
// plot violin chart
vioplot diff, title("Violin Plot of Home Team - Away Team Goal Difference") ///
    graphregion(color(white)) ///
    ylabel(, angle(0) nogrid) ///
    plotregion(margin(0 5 0 5)) ///
    lcolor(blue) lwidth(medium) fcolor(%80) ///
    ytitle("Density") ///
    aspect(1) ///
    legend(off)
// save graph
cd "$result"
graph export "football_violin.png"
