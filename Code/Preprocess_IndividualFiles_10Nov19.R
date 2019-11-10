##################################################################################################
#### Introduction ####

## Title: F1 Preprocessing - Individual Source Files
## Author: Tyler Campbell
## Date: Nov 2019

## IMPORTANT: If running full script (and not wanting to overwrite files), avoid 'Write files' section at bottom

## Description:
  # This R script performs cleaning of individual raw F1 source data files
  # Sections are arranged in alphabetical order and contain section-specific notes
  # A separate script will be created for binding the data frames
  
## Source Dataset Descriptions:
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




##### Load packages ####
install.packages("tidyverse")
install.packages("chron")
library(tidyverse)
library(lubridate)
library(chron)




#### Load files ####

# define input path
path_in <- "./Raw Source Data"

# read files
circuits <- read.csv(file.path(path_in, "circuits.csv"), stringsAsFactors = F)
constructorResults <- read.csv(file.path(path_in, "constructorResults.csv"), stringsAsFactors = F)
constructors <- read.csv(file.path(path_in, "constructors.csv"), stringsAsFactors = F)
constructorStandings <- read.csv(file.path(path_in, "constructorStandings.csv"), stringsAsFactors = F)
drivers <- read.csv(file.path(path_in, "drivers.csv"), stringsAsFactors = F)
driverStandings <- read.csv(file.path(path_in, "driverStandings.csv"), stringsAsFactors = F)
lapTimes <- read.csv(file.path(path_in, "lapTimes.csv"), stringsAsFactors = F)
pitStops <- read.csv(file.path(path_in, "pitStops.csv"), stringsAsFactors = F)
qualifying <- read.csv(file.path(path_in, "qualifying.csv"), stringsAsFactors = F, skipNul = TRUE, na.strings = c("","NULL","NA")) # also convert embedded NULLs and blanks to NA))
races <- read.csv(file.path(path_in, "races.csv"), stringsAsFactors = F, skipNul = TRUE, na.strings = c("","NULL","NA")) # also convert embedded NULLs and blanks to NA))
results <- read.csv(file.path(path_in, "results.csv"), stringsAsFactors = F, na.strings = c("","NULL","NA")) # also convert embedded NULLs and blanks to NA))
seasons <- read.csv(file.path(path_in, "seasons.csv"), stringsAsFactors = F)
status <- read.csv(file.path(path_in, "status.csv"), stringsAsFactors = F)




#### Clean data ####

## circuits -------------------------------------------------------------------------------

# inspect file for completeness
colSums(circuits == "" | circuits == "NULL" | is.na(circuits))

# remove columns: 'name', 'alt' ('name' is dirtier and lengthier than 'circuitRef' & 'alt' appears to have no meaning)
# keep columns: 'url', 'lat', 'long' in case wanting to scrape wiki pages and/or calculate distance (e.g. from home)
circuits <- subset(circuits, select = -c(name, alt))

# clean dirty location names (caused by accent characters)
circuits[c(4,18,20), "location"] <- c("Montmelo", "Sao Paulo", "Nurburg")

# rename columns
circuits <- circuits %>%
  rename("circuit_name" = "circuitRef",
         "circuit_city" = "location",
         "circuit_country" = "country",
         "circuit_lat" = "lat",
         "circuit_long" = "lng",
         "circuit_url" = "url"
         )




## constructorResults -------------------------------------------------------------------------------

# 'D' in 'status' column represents 'Disqualified' due to Spygate scandal in 2007 season (https://en.wikipedia.org/wiki/2007_Formula_One_espionage_controversy)

# inspect file for completeness
colSums(constructorResults == "" | constructorResults == "NULL" | is.na(constructorResults))

# inspect distribution of 'status' (see above description of 'D') & remove column
table(constructorResults$status)
constructorResults <- subset(constructorResults, select = -status)

# convert 'points' to int type
constructorResults$points <- as.integer(constructorResults$points)

# rename columns
constructorResults <- constructorResults %>%
  rename("constructorResult_pointsPerRace" = "points")




## constructors --------------------------------------------------------------------------------

# again keeping 'url' column incase of desire to scrape

# inspect for completeness
colSums(constructors == "" | constructors == "NULL" | is.na(constructors))

# remove columns: 'name', 'X' ('X' is entirely NA values)
constructors <- subset(constructors, select = -c(X, name))

# rename columns
constructors <- constructors %>%
  rename("constructor_name" = "constructorRef",
         "constructor_nationality" = "nationality",
         "constructor_url" = "url"
         )




## constructorStandings -------------------------------------------------------------------------------

# inspect file for completeness
colSums(constructorStandings == "" | constructorStandings == "NULL" | is.na(constructorStandings))

# remove column: 'positionText' ('positionText' is identical to 'position' with the exception of 'E' for excluded due to "Spygate" scandal (see constructorResults section))
# remove column: 'X' ('X' is entirely NA values)
constructorStandings <- subset(constructorStandings, select = -c(positionText, X))

# convert 'points' to int type
constructorStandings$points <- as.integer(constructorStandings$points)

# rename columns
constructorStandings <- constructorStandings %>%
  rename("constructorStanding_runningTotalPointsInSeason" = "points",
         "constructorStanding_runningPositionInSeason" = "position",
         "constructorStanding_runningTotalWinsInSeason" = "wins"
         )




## drivers -------------------------------------------------------------------------------

# inspect file for completeness
colSums(drivers == "" | drivers == "NULL" | is.na(drivers))

# remove column: 'number' ('number' is arbitrary driver/car number)
# remove columns: 'code' 'forename', 'surname' ('code' serves no purpose $ forename' and 'surname' are messier and lengthier than 'driverRef')
drivers <- subset(drivers, select = -c(number, code, forename, surname))

# clean dob column and convert to date type variable using lubridate function
drivers[415, "dob"] <- "12/08/1993"
drivers$dob <- dmy(drivers$dob)

# manually handle the 7 records that failed to parse and re-run lubridate
drivers[c(590, 704, 742, 751, 761, 787, 792), "dob"] <-
  c("1899-08-03", "1898-11-01", "1896-12-28", "1899-10-15", "1899-10-13", "1898-06-09", "1898-10-18")
drivers$dob <- ymd(drivers$dob)

# rename columns
drivers <- drivers %>%
  rename("driver_Name" = "driverRef",
         "driver_dob" = "dob",
         "driver_nationality" = "nationality",
         "driver_url" = "url"
         )




## driverStandings -------------------------------------------------------------------------------

# thought: if you could associate a race with its round #, then driver with most points after final round wins championship

# inspect file for completeness
colSums(driverStandings == "" | driverStandings == "NULL" | is.na(driverStandings))

# remove column: 'positionText' ('positionText' is identical to 'position' with the exception of 'D' for disqualification from the championship due to intentional collision)
driverStandings <- subset(driverStandings, select = -positionText)

# convert 'points' to int type
driverStandings$points <- as.integer(driverStandings$points)

# rename columns
driverStandings <- driverStandings %>%
  rename("driverStanding_runningTotalPointsInSeason" = "points",
         "driverStanding_runningPositionInSeason" = "position",
         "driverStanding_runningTotalWinsInSeason" = "wins"
         )




## lapTimes -------------------------------------------------------------------------------

# file is missing lap times from at least races 400-800 (by raceID)
# consider excluding lap 25 of raceId 847 (2011 Canadian Grand Prix had "torrential rains" that caused a single lap to clock in at over 2 hrs)
# consider excluding file altogether

# inspect file for completeness
colSums(lapTimes == "" | lapTimes == "NULL" | is.na(lapTimes))
hist(lapTimes$raceId)

# remove column: 'time' ('time' == 'milliseconds')
lapTimes <- subset(lapTimes, select = -time)

# create an average lap time column
lapTimes <- lapTimes %>%
  group_by(raceId, driverId) %>%
  mutate(lapTime_avgMillisec = as.integer(mean(milliseconds)))

# ungroup columns and convert back to data frame
lapTimes <- lapTimes %>%
  ungroup() %>%
  as.data.frame()

# rename columns
lapTimes <- lapTimes %>%
  rename("lapTime_positionInLap" = "position",
         "lapTime_millisec" = "milliseconds"
         )




## pitStops -------------------------------------------------------------------------------

# file excludes races before 2011 and after 2017
# consider aggregating 'milliseconds' per driver per race to obtain a single total pit time per race
# consider obtaining largest number of 'stop' per driver per race to get total number of pit stops per race
# consider excluding file altogether

# inspect file for completeness
colSums(pitStops == "" | pitStops == "NULL" | is.na(pitStops))
hist(pitStops$raceId)

# remove column: 'duration' ('duration' == 'milliseconds')
pitStops <- subset(pitStops, select = -duration)

# create a total number of stops per race column
pitStops <- pitStops %>%
    group_by(raceId, driverId) %>%
    arrange(raceId, driverId, stop) %>%
    mutate(pitStop_totalStops = last(stop))

# create an average pitstop duration column
pitStops <- pitStops %>%
    group_by(raceId, driverId) %>%
    mutate(pitStop_avgDuration = as.integer(mean(milliseconds)))

# ungroup columns and convert back to data frame
pitStops <- pitStops %>%
  ungroup() %>%
  as.data.frame()

# rename columns
pitStops <- pitStops %>%
  rename("pitStop_stopNum" = "stop",
         "pitStop_lap" = "lap",
         "pitStop_timeOfDay" = "time",
         "pitStop_durationMillisec" = "milliseconds"
         )




## qualifying -------------------------------------------------------------------------------

# 'position' should be the same as grid in results file
# consider excluding file altogether because of NAs

# inspect file for completeness 
colSums(qualifying == "" | qualifying == "NULL" | is.na(qualifying))

# remove column: 'number' ('number' is arbitrary driver/car number)
qualifying <- subset(qualifying, select = -number)

# correct erroneous record in q2
qualifying[5663, "q2"] <- "1:48.552"

# convert 'q1':'q3' to milliseconds
qualifying <- qualifying %>%
  separate(q1, into = c("q1_minuteSecond", "q1_decimal"), sep = "\\.") %>%
  separate(q1_minuteSecond, into = c("q1_minute", "q1_second"), convert = TRUE) %>%
  mutate(q1_milliseconds = paste0(((q1_minute * 60) + q1_second), q1_decimal))

qualifying <- qualifying %>%
  separate(q2, into = c("q2_minuteSecond", "q2_decimal"), sep = "\\.") %>%
  separate(q2_minuteSecond, into = c("q2_minute", "q2_second"), convert = TRUE) %>%
  mutate(q2_milliseconds = paste0(((q2_minute * 60) + q2_second), q2_decimal))

qualifying <- qualifying %>%
  separate(q3, into = c("q3_minuteSecond", "q3_decimal"), sep = "\\.") %>%
  separate(q3_minuteSecond, into = c("q3_minute", "q3_second"), convert = TRUE) %>%
  mutate(q3_milliseconds = paste0(((q3_minute * 60) + q3_second), q3_decimal))

# convert 'NANA's (caused by concatenation) to NAs
qualifying[qualifying == "NANA"] <- NA

# remove columns: 'q1_minute' through 'q3_decimal' (temp columns created for parsing)
qualifying <- subset(qualifying, select = -c(q1_minute:q3_decimal))

# rename columns
qualifying <- qualifying %>%
  rename("qualifying_finishPosition" = "position",
         "qualifying_q1Millisec" = "q1_milliseconds",
         "qualifying_q2Millisec" = "q2_milliseconds",
         "qualifying_q3Millisec" = "q3_milliseconds"
         )




## races -------------------------------------------------------------------------------

# race time is empty from 1950 to 2005
# consider removing 'time'
# remove 'name' which will be redundant after merge (circuit table contains ref)

# inspect file for completeness
colSums(races == "" | races == "NULL" | is.na(races))

# convert 'date' to date type
races$date <- ymd(races$date)

# convert 'time' to time type
races$time <- times(races$time)

# rename columns
races <- races %>%
  rename("race_year" = "year",
         "race_round" = "round",
         "race_name" = "name",
         "race_date" = "date",
         "race_time" = "time",
         "race_url" = "url"
         )




## results -------------------------------------------------------------------------------

# 'time' is inconsistently represented as minutes:seconds beyond 1 hr for first place driver, then the gap for next several drivers
# no time is recorded for racers greater than 1 lap behind the winner
# consider just including 'time' for winner, otherwise it's reflected as "gap" and often +1 laps rather than a time
# 'position' = raceFinish, 'positionText' = raceFinish or descriptor of retired/disqualified etc., 'positionOrder' = raceFinish or order of retired/disqualified
# positionText: D=Disqualified, E=Excluded, F=Did Not (/failed to) Qualify, N=Not Classified, R=Retired, W=Withrew
# consider converting 'positionText' to boolean (i.e. Finished, Did not finish)
# fastest lap data is empty or NA from 1950 to 2004
# 'grid' is mostly a duplicate of position in qualifying table, but is likely more reliable

# inspect file for completeness
colSums(results == "" | results == "NULL" | is.na(results))

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
                  "Finished"
                  )))))))
results <- subset(results, select = -positionText)

# convert fastestLapTime to milliseconds
results <- results %>%
  separate(fastestLapTime, into = c("fLT_minuteSecond", "fLT_decimal"), sep = "\\.") %>%
  separate(fLT_minuteSecond, into = c("fLT_minute", "fLT_second"), convert = TRUE) %>%
  mutate(fLT_milliseconds = paste0(((fLT_minute * 60) + fLT_second), fLT_decimal, "00"))

# convert 'NANA00's (caused by concatenation) to NAs
results$fLT_milliseconds[results$fLT_milliseconds == "NANA00"] <- NA

# convert 'points', 'fastestLapSpeed', and 'fLT_milliseconds' to appropriate number types
results$points <- as.integer(results$points)
results$fLT_milliseconds <- as.integer(results$fLT_milliseconds)
results$fastestLapSpeed <- as.double(results$fastestLapSpeed)

# remove columns: 'q1_minute' through 'q3_decimal' (temp columns created for parsing)
results <- subset(results, select = -c(fLT_minute:fLT_decimal))

# rename columns
results <- results %>%
  rename("result_startingGridPosition" = "grid",
         "result_finishOrder" = "positionOrder",
         "result_pointsEarned" = "points",
         "result_lapsCompleted" = "laps",
         "result_finishTimeMillisec" = "milliseconds",
         "result_fastestLapTimeMillisec" = "fLT_milliseconds",
         "result_fastestLap" = "fastestLap",
         "result_fastestLapRank" = "rank",
         "result_fastestLapSpeed" = "fastestLapSpeed"
         )




## seasons -------------------------------------------------------------------------------

# somewhat irrelevant file unless wanting to scrape wiki pages

# inspect file for completeness
colSums(seasons == "" | seasons == "NULL" | is.na(seasons))

# convert year to date type
seasons$year <- as.character(seasons$year)
seasons$year <- as.Date(paste(seasons$year, 1, 1, sep = "-")) # beginning of year
seasons$year <- as.Date(paste(seasons$year, 12, 31, sep = "-")) # end of year

# rename columns
seasons <- seasons %>%
  rename("season_year" = "year",
         "season_url" = "url"
         )




## status -------------------------------------------------------------------------------

# inspect file for completeness
colSums(status == "" | status == "NULL" | is.na(status))

# rename column
colnames(status) [colnames(status) == "status"] <- "status_description"




#### Write files ####

# define output path
path_out <- "./Processed Data"

# write to csvs
write.csv(circuits, file.path(path_out, "circuits_clean.csv"), row.names=FALSE)
write.csv(constructorResults, file.path(path_out, "constructorResults_clean.csv"), row.names=FALSE)
write.csv(constructors, file.path(path_out, "constructors_clean.csv"), row.names=FALSE)
write.csv(constructorStandings, file.path(path_out, "constructorStandings_clean.csv"), row.names=FALSE)
write.csv(drivers, file.path(path_out, "drivers_clean.csv"), row.names=FALSE)
write.csv(driverStandings, file.path(path_out, "driverStandings_clean.csv"), row.names=FALSE)
write.csv(lapTimes, file.path(path_out, "lapTimes_clean.csv"), row.names=FALSE)
write.csv(pitStops, file.path(path_out, "pitStops_clean.csv"), row.names=FALSE)
write.csv(qualifying, file.path(path_out, "qualifying_clean.csv"), row.names=FALSE)
write.csv(races, file.path(path_out, "races_clean.csv"), row.names=FALSE)
write.csv(results, file.path(path_out, "results_clean.csv"), row.names=FALSE)
write.csv(seasons, file.path(path_out, "seasons_clean.csv"), row.names=FALSE)
write.csv(status, file.path(path_out, "status_clean.csv"), row.names=FALSE)


