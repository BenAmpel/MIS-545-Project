##################################################################################################
## README ##

# Title: F1 Data Cleaning
# Author: Tyler Campbell
# Date: Nov 2019
# Description:
  # This script cleans F1 data downloaded from Kaggle
  # Files are arranged in alphabetical order
# Source Data Files Descriptions:
  # circuits: circuit name, location, and wiki page url
  # constructorResults: aggregated constructor points earned per race
  # constructors: constructor name, nationality, and wiki page url
  # constructorStandings: running/accumulated 'points' and 'wins' for constructors in a given season
  # drivers: driver name, number, dob, nationality, and wiki page url
  # driverStandings: accumulated driver points and wins for a given season
  # lapTimes: lap time and position for each driver in each lap of each race
  # pitStops: stop number and stop duration/milliseconds of each pitstop at a given time of day on a given lap by a given driver
  # qualifying: qualifying times (and final qualifying position) for each driver of each race
  # races: race name, date, and time for each seasons, and wiki page url
  # *results*: results of every race (*critical file containing dependent variables*)
  # seasons: year and wiki page url of each season
  # status: key and description of race results (e.g. finished, +1 Lap, collision, etc.)

##################################################################################################



# load packages
install.packages("tidyverse")
install.packages("chron")
library(tidyverse)
library(lubridate)
library(chron)



#####################
# clean circuits data
#####################
# read circuits file
circuits <- read.csv('./Formula 1 data/circuits.csv', stringsAsFactors = F)

# remove columns: 'name', 'alt' ('name' is dirtier and lengthier than 'circuitRef' & 'alt' appears to have no meaning)
# keep columns: 'url', 'lat', 'long' in case wanting to scrape wiki pages and/or calculate distance (e.g. from home)
circuits <- subset(circuits, select = -c(name, alt)) 

# clean dirty location names (caused by accent characters)
circuits$location[4] <- "Montmelo" 
circuits$location[18] <- "Sao Paulo"
circuits$location[20] <- "Nurburg"

# rename columns
colnames(circuits) [colnames(circuits) == "circuitRef"] <- "circuit_name"
colnames(circuits) [colnames(circuits) == "location"] <- "circuit_city"
colnames(circuits) [colnames(circuits) == "country"] <- "circuit_country"
colnames(circuits) [colnames(circuits) == "lat"] <- "circuit_lat"
colnames(circuits) [colnames(circuits) == "lng"] <- "circuit_long"
colnames(circuits) [colnames(circuits) == "url"] <- "circuit_url"



###############################
# clean constructorResults data
###############################
# 'D' in 'status' column represents 'Disqualified' due to Spygate scandal in 2007 season (https://en.wikipedia.org/wiki/2007_Formula_One_espionage_controversy)

# read constructorResults file
constructorResults <- read.csv('./Formula 1 data/constructorResults.csv', stringsAsFactors = F)

#check distribution of 'status' (see above description of 'D') & remove column
table(constructorResults$status)
constructorResults <- subset(constructorResults, select = -status)

# convert 'points' to int type
constructorResults$points <- as.integer(constructorResults$points)

# rename columns
colnames(constructorResults) [colnames(constructorResults) == "points"] <- "constructorResult_pointsPerRace"



#########################
# clean constructors data
#########################
# again keeping 'url' column incase of desire to scrape

# read constructors file
constructors <- read.csv('./Formula 1 data/constructors.csv', stringsAsFactors = F)

# remove columns: 'name', 'X' ('X' is entirely NA values)
constructors <- subset(constructors, select = -c(X, name))

# rename columns
colnames(constructors) [colnames(constructors) == "constructorRef"] <- "constructor_name"
colnames(constructors) [colnames(constructors) == "nationality"] <- "constructor_nationality"
colnames(constructors) [colnames(constructors) == "url"] <- "constructor_url"



#################################
# clean constructorStandings data
#################################
# read constructorStandings file
constructorStandings <- read.csv('./Formula 1 data/constructorStandings.csv', stringsAsFactors = F)

# remove column: 'positionText' ('positionText' is identical to 'position' with the exception of 'E' for excluded due to 2007 "Spygate" scandal (see constructorResults section))
# remove column: 'X' ('X' is entirely NA values)
constructorStandings <- subset(constructorStandings, select = -c(positionText, X))

# convert 'points' to int type
constructorStandings$points <- as.integer(constructorStandings$points)

# rename columns
colnames(constructorStandings) [colnames(constructorStandings) == "points"] <- "constructorStanding_runningTotalPointsInSeason"
colnames(constructorStandings) [colnames(constructorStandings) == "position"] <- "constructorStanding_runningPositionInSeason"
colnames(constructorStandings) [colnames(constructorStandings) == "wins"] <- "constructorStanding_runningTotalWinsInSeason"



####################
# clean drivers data
####################
# read drivers file
drivers <- read.csv('./Formula 1 data/drivers.csv', stringsAsFactors = F)

# remove column: 'number' ('number' is arbitrary driver/car number)
# remove columns: 'code' 'forename', 'surname' ('code' serves no purpose $ forename' and 'surname' are messier and lengthier than 'driverRef')
drivers <- subset(drivers, select = -c(number, code, forename, surname))

# clean dob column and convert to date type variable using lubridate function
drivers$dob[415] <- "12/08/1993"
drivers$dob <- dmy(drivers$dob)

# manually handle the 7 records that failed to parse and re-run lubridate
drivers$dob[590] <- "1899-08-03"
drivers$dob[704] <- "1898-11-01"
drivers$dob[742] <- "1896-12-28"
drivers$dob[751] <- "1899-10-15"
drivers$dob[761] <- "1899-10-13"
drivers$dob[787] <- "1898-06-09"
drivers$dob[792] <- "1898-10-18"
drivers$dob <- ymd(drivers$dob)

# rename columns
colnames(drivers) [colnames(drivers) == "driverRef"] <- "driver_Name"
colnames(drivers) [colnames(drivers) == "dob"] <- "driver_dob"
colnames(drivers) [colnames(drivers) == "nationality"] <- "driver_nationality"
colnames(drivers) [colnames(drivers) == "url"] <- "driver_url"



############################
# clean driverStandings data
############################
# thought: if you could associate a race with its round #, then driver with most points at final round wins championship

# read driverStandings file
driverStandings <- read.csv('./Formula 1 data/driverStandings.csv', stringsAsFactors = F)

# remove column: 'positionText' ('positionText' is identical to 'position' with the exception of 'D' for disqualification from the championship due to intentional collision)
driverStandings <- subset(driverStandings, select = -positionText)

# convert 'points' to int type
driverStandings$points <- as.integer(driverStandings$points)

# rename columns
colnames(driverStandings) [colnames(driverStandings) == "points"] <- "driverStanding_runningTotalPointsInSeason"
colnames(driverStandings) [colnames(driverStandings) == "position"] <- "driverStanding_runningPositionInSeason"
colnames(driverStandings) [colnames(driverStandings) == "wins"] <- "driverStanding_runningTotalWinsInSeason"



#####################
# clean lapTimes data
#####################
# consider excluding lap-25 of raceId-847 (2011 Canadian Grand Prix had "torrential rains" that caused a single lap to clock in at over 2 hrs)
# consider excluding file altogether

# read lapTimes file
lapTimes <- read.csv('./Formula 1 data/lapTimes.csv', stringsAsFactors = F)

# remove column: 'time' ('time' == 'milliseconds')
lapTimes <- subset(lapTimes, select = -time)

# create an average lap time column
lapTimes <- lapTimes %>%
  group_by(raceId, driverId) %>%
  mutate(lapTime_avgLapTime = as.integer(mean(milliseconds)))

# ungroup columns
lapTimes <- ungroup(lapTimes)

# rename columns
colnames(lapTimes) [colnames(lapTimes) == "position"] <- "lapTime_positionInLap"
colnames(lapTimes) [colnames(lapTimes) == "milliseconds"] <- "lapTime"



#####################
# clean pitStops data
#####################
# file excludes races before 2011 and after 2017
# consider aggregating 'milliseconds' per driver per race to obtain a single total pit time per race
# consider obtaining largest number of 'stop' per driver per race to get total number of pit stops per race
# consider excluding file altogether

# read pitStops file
pitStops <- read.csv('./Formula 1 data/pitStops.csv', stringsAsFactors = F)

# remove column: 'duration' ('duration' == 'milliseconds')
pitStops <- subset(pitStops, select = -duration)

# create a total number of stops per race column
pitStops <- pitStops %>%
    group_by(raceId, driverId) %>%
    arrange(raceId, driverId, stop) %>%
    mutate(pitStop_numOfStops = last(stop))

# create an average pitstop duration column
pitStops <- pitStops %>%
    group_by(raceId, driverId) %>%
    mutate(pitStop_avgDuration = as.integer(mean(milliseconds)))

# ungroup columns
pitStops <- ungroup(pitStops)

# rename columns
colnames(pitStops) [colnames(pitStops) == "stop"] <- "pitStop_stopNum"
colnames(pitStops) [colnames(pitStops) == "lap"] <- "pitStop_lap"
colnames(pitStops) [colnames(pitStops) == "time"] <- "pitStop_timeOfDay"
colnames(pitStops) [colnames(pitStops) == "milliseconds"] <- "pitStop_durationMilliseconds"



#######################
# clean qualifying data
#######################
# 'position' should be the same as grid in results file 
# consider excluding file altogether because of NAs

# read qualifying file
qualifying <- read.csv('./Formula 1 data/qualifying.csv', stringsAsFactors = F)

# remove column: 'number' ('number' is arbitrary driver/car number)
qualifying <- subset(qualifying, select = -number)

# convert NULLs and blanks to NA 
qualifying[qualifying == "NULL"] <- NA
qualifying[qualifying == ""] <- NA

# convert 'q1' to milliseconds
qualifying <- separate(qualifying, q1, into = c("q1_minuteSecond", "q1_decimal"), sep = "\\.")
qualifying <- separate(qualifying, q1_minuteSecond, into = c("q1_minute", "q1_second"), convert = TRUE)
qualifying <- mutate(qualifying, q1_milliseconds = paste0(((qualifying$q1_minute * 60) + qualifying$q1_second), qualifying$q1_decimal))


# convert 'q2' to milliseconds
qualifying <- separate(qualifying, q2, into = c("q2_minuteSecond", "q2_decimal"), sep = "\\.")
qualifying <- separate(qualifying, q2_minuteSecond, into = c("q2_minute", "q2_second"), convert = TRUE)
qualifying <- mutate(qualifying, q2_milliseconds = paste0(((qualifying$q2_minute * 60) + qualifying$q2_second), qualifying$q2_decimal))

# convert 'q3' to milliseconds
qualifying <- separate(qualifying, q3, into = c("q3_minuteSecond", "q3_decimal"), sep = "\\.")
qualifying <- separate(qualifying, q3_minuteSecond, into = c("q3_minute", "q3_second"), convert = TRUE)
qualifying <- mutate(qualifying, q3_milliseconds = paste0(((qualifying$q3_minute * 60) + qualifying$q3_second), qualifying$q3_decimal))

#convert NANAs (caused by concatenation) to NAs
qualifying[qualifying == "NANA"] <- NA

# remove columns: 'q1_minute' through 'q3_decimal' (temp columns needed for parsing)
qualifying <- subset(qualifying, select = -c(q1_minute:q3_decimal))

# rename columns
colnames(qualifying) [colnames(qualifying) == "position"] <- "qualifying_finishPosition"
colnames(qualifying) [colnames(qualifying) == "q1_milliseconds"] <- "qualifying_q1Milliseconds"
colnames(qualifying) [colnames(qualifying) == "q2_milliseconds"] <- "qualifying_q2Milliseconds"
colnames(qualifying) [colnames(qualifying) == "q3_milliseconds"] <- "qualifying_q3Milliseconds"



##################
# clean races data
##################
# race time is empty from 1950 to 2005
# consider removing 'time', keep 'round' and/or 'date' instead which is more complete
# remove 'name' which will be redundant after merge (circuit table contains ref)

# read races file
races <- read.csv('./Formula 1 data/races.csv', stringsAsFactors = F)

# convert any NULLs and blanks to NA
races[races == "NULL"] <- NA
races[races == ""] <- NA

# convert 'date' to date type
races$date <- ymd(races$date)

# convert 'time' to time type
races$time <- times(races$time)

# rename columns
colnames(races) [colnames(races) == "year"] <- "race_year"
colnames(races) [colnames(races) == "round"] <- "race_round"
colnames(races) [colnames(races) == "name"] <- "race_name"
colnames(races) [colnames(races) == "date"] <- "race_date"
colnames(races) [colnames(races) == "time"] <- "race_time"
colnames(races) [colnames(races) == "url"] <- "race_url"



####################
# clean results data
####################
# 'time' is inconsistently represented as minutes:seconds beyond 1 hr for first place driver, then the gap for next several drivers
# no time is recorded for racers greater than 1 lap behind the winner
# consider just including 'time' for winner, otherwise it's reflected as "gap" and often +1 laps rather than a time
# 'position' = raceFinish, 'positionText' = raceFinish or descriptor of retired/disqualified etc., 'positionOrder' = raceFinish or order of retired/disqualified
# positionText: D=Disqualified, E=Excluded, F=Did Not (/failed to) Qualify, N=Not Classified, R=Retired, W=Withrew
# consider converting 'positionText' to boolean (i.e. Finished, Did not finish)
# consider reyling most on 'positionOrder'
# fastest lap data is empty or NA from 1950 to 2004
# 'grid' is mostly a duplicate of position in qualifying table, but is likely more reliable

# read results file (most important - contains our dependent variables)
results <- read.csv('./Formula 1 data/results.csv', stringsAsFactors = F)

# remove columns: 'position', 'number', 'time', 'fastestLap', 'rank', 'fastestLapTime', 'fastestLapSpeed'
# ('position' is redundant, 'number' is arbitrary driver/car number, 'time' is represented more cleanly in 'milliseconds')
results <- subset(results, select = -c(position, number, time))

# convert positionText column to finish description
results <- mutate(results, results_finishDescription = 
                    ifelse(results$positionText == "D", "Disqualified",
                    ifelse(results$positionText == "E", "Excluded",
                    ifelse(results$positionText == "F", "FailedToFinish",
                    ifelse(results$positionText == "N", "NotClassified",
                    ifelse(results$positionText == "R", "Retired",
                    ifelse(results$positionText == "W", "Withdrew",
                    "Finished")))))))
results <- subset(results, select = -positionText)

# convert fastestLapTime to milliseconds
results <- separate(results, fastestLapTime, into = c("fLT_minuteSecond", "fLT_decimal"), sep = "\\.")
results <- separate(results, fLT_minuteSecond, into = c("fLT_minute", "fLT_second"), convert = TRUE)
results <- mutate(results, fLT_milliseconds = paste0(((results$fLT_minute * 60) + results$fLT_second), results$fLT_decimal, "00"))

#convert NANA00s (caused by concatenation) to NAs
results$fLT_milliseconds[results$fLT_milliseconds == "NANA00"] <- NA

# remove columns: 'q1_minute' through 'q3_decimal' (temp columns needed for parsing)
results <- subset(results, select = -c(fLT_minute:fLT_decimal))

# rename columns
colnames(results) [colnames(results) == "grid"] <- "result_startingGridPosition"
colnames(results) [colnames(results) == "positionOrder"] <- "result_finishOrder"
colnames(results) [colnames(results) == "points"] <- "result_pointsEarned"
colnames(results) [colnames(results) == "laps"] <- "result_lapsCompleted"
colnames(results) [colnames(results) == "milliseconds"] <- "result_finishTimeMilliseconds"
colnames(results) [colnames(results) == "fLT_milliseconds"] <- "result_fastestLapTimeMilliseconds"
colnames(results) [colnames(results) == "fastestLap"] <- "result_fastestLap"
colnames(results) [colnames(results) == "rank"] <- "result_fastestLapRank"
colnames(results) [colnames(results) == "fastestLapSpeed"] <- "result_fastestLapSpeed"



####################
# clean seasons data
####################
# somewhat irrelevant file unless wanting to scrape wiki pages
# F1 seasons do not overlap years

# read seasons file
seasons <- read.csv('./Formula 1 data/seasons.csv', stringsAsFactors = F)

# convert year to date type
seasons$year <- as.character(seasons$year)
seasons$year <- as.Date(paste(seasons$year, 1, 1, sep = "-")) # beginning of year
seasons$year <- as.Date(paste(seasons$year, 12, 31, sep = "-")) # end of year

# rename columns
colnames(seasons) [colnames(seasons) == "year"] <- "season_year"
colnames(seasons) [colnames(seasons) == "url"] <- "season_url"



###################
# clean status data
###################
# read status file
status <- read.csv('./Formula 1 data/status.csv', stringsAsFactors = F)

# rename columns
colnames(status) [colnames(status) == "status"] <- "status_description"
