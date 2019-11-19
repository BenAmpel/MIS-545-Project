##################################################################################################
#### Introduction ####

## Title: F1 Preprocessing - Join Source Data
## Author: Tyler Campbell
## Date: Nov 2019

## IMPORTANT:
  # Run this script after running 'Preprocess_IndividualFiles_10Nov19'
  # If running full script (and not wanting to overwrite files), avoid 'Write files' section at bottom

## Description:
# This R script performs joining and cleaning of processed F1 source data
# Sections are arranged in reverse-alphabetical order and contain section-specific notes
# In future iterations, two joins will be performed:
  # 'Historical' - maximizes results back to 1950, but excludes newer measures such as fastest lap data
  # 'Modern' - includes newer measures, but excludes records before 2011

##################################################################################################




#### Source Dataset Descriptions ####

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




#### Load packages ####

install.packages("tidyverse")
library(tidyverse)




#### Join Data Frames ####

## Historical -------------------------------------------------------------------------------

# This join focuses on maximizing historical data at the expense of newer measures such as pitStops and lapTimes
  # (i.e. excludes data such as pitStop times which are only recorded beginning in 2011)

# join tables beginning from 'results' in reverse alphabetical order
# confirm primary key
results %>%
  count(resultId) %>%
  filter(n > 1)


# join status
resultsHistorical <- results %>%
  left_join(status, by = "statusId") %>%
  select(-statusId)


# exclude seasons


# join races
resultsHistorical <- resultsHistorical %>%
  left_join(races, by = "raceId") %>%
  select(-race_name, -race_year, -race_time, -race_url)


# exclude qualifying


# exclude pitStops


# exclude lapTimes


# join driverStandings
# confirm primary key
driverStandings %>%
  count(raceId, driverId) %>%
  filter(n > 1)
  
resultsHistorical <- resultsHistorical %>%
  left_join(driverStandings, by = c("raceId", "driverId")) %>%
  select(-driverStandingsId)


# join drivers
resultsHistorical <- resultsHistorical %>%
  left_join(drivers, by = "driverId") %>%
  select(-driverId, -driver_url)


# join constructorStandings
# confirm primary key
constructorStandings %>%
  count(raceId, constructorId) %>%
  filter(n > 1)

resultsHistorical <- resultsHistorical %>%
  left_join(constructorStandings, by = c("raceId", "constructorId")) %>%
  select(-constructorStandingsId)


# join constructors
resultsHistorical <- resultsHistorical %>%
  left_join(constructors, by = "constructorId") %>%
  select(-constructor_url)


# join constructorResults
# confirm primary key
constructorResults %>%
  count(raceId, constructorId) %>%
  filter(n > 1)

# remove duplicate records
constructorResults <- constructorResults[-c(9632, 10355),]

resultsHistorical <- resultsHistorical %>%
  left_join(constructorResults, by = c("raceId", "constructorId")) %>%
  select(-constructorResultsId, -constructorId)


# join circuits
resultsHistorical <- resultsHistorical %>%
  left_join(circuits, by = "circuitId") %>%
  select(-circuitId, -circuit_url, -circuit_lat, -circuit_long)




#### Clean Newly Merged Data Frame ####

# consider converting points earned to boolean
# consider creating a normalized column of % of total laps finished in previous race round

# inspect df
glimpse(resultsHistorical)
summary(resultsHistorical)
colSums(is.na(resultsHistorical))
head(resultsHistorical)


#normalize laps completed field
resultsHistorical <- resultsHistorical %>%
  group_by(raceId) %>%
  mutate(maxLaps = max(result_lapsCompleted),
         result_percentOfRaceCompleted = (result_lapsCompleted / maxLaps) * 100,
         result_lapsCompleted = NULL,
         maxLaps = NULL
         )

# ungroup columns
resultsHistorical <- resultsHistorical %>%
  ungroup() %>%
  as.data.frame()

# remove resultId column which is no longer needed
resultsHistorical <- subset(resultsHistorical, select = -resultId)


# remove result_finishTimeMillisec due to difficult to handle NAs
resultsHistorical <- subset(resultsHistorical, select = -result_finishTimeMillisec)


# remove columns relating to fastest lap data which contain many untreatable NAs
resultsHistorical <- subset(resultsHistorical, select = -c(result_fastestLap:result_fastestLapSpeed, result_fastestLapTimeMillisec))


# fill NAs in 'points' & 'wins' related columns with 0 and remove 'position' related columns
  # NAs in 'driverStandings.' and 'consturctorStandings.' caused by failures to qualify in early season races
  # attempt later -- [fill NAs in 'position' columns with *max runningPositionsInSeason + 1* for each season]
    # use grouped mutate (window function)
resultsHistorical$driverStanding_runningTotalPointsInSeason[is.na(resultsHistorical$driverStanding_runningTotalPointsInSeason)] <- 0

resultsHistorical$driverStanding_runningTotalWinsInSeason[is.na(resultsHistorical$driverStanding_runningTotalWinsInSeason)] <- 0

resultsHistorical <- subset(resultsHistorical, select = -driverStanding_runningPositionInSeason)

resultsHistorical$constructorStanding_runningTotalPointsInSeason[is.na(resultsHistorical$constructorStanding_runningTotalPointsInSeason)] <- 0

resultsHistorical$constructorStanding_runningTotalWinsInSeason[is.na(resultsHistorical$constructorStanding_runningTotalWinsInSeason)] <- 0

resultsHistorical$constructorResult_pointsPerRace[is.na(resultsHistorical$constructorResult_pointsPerRace)] <- 0

resultsHistorical <- subset(resultsHistorical, select = -constructorStanding_runningPositionInSeason)


# create driver age at time of race feature and convert to int
# remove 'driver_dob' (consider re-adding in future to analyze race results on closeness to birthday)
resultsHistorical <- resultsHistorical %>%
  mutate(driverAge = (race_date - driver_dob) / 365,
         driver_dob = NULL
         )

resultsHistorical$driverAge <- as.integer(resultsHistorical$driverAge)

# correct outlier
resultsHistorical[17012, "driverAge"] = 33


# convert race date to month and year columns (for better factorization)
# remove 'race_date'
resultsHistorical <- resultsHistorical %>%
  mutate(race_month = month(race_date),
         race_year = year(race_date),
         race_date = NULL
         )


# create race in driver home country? and constructor home country (True or False) feature and remove existing fields
resultsHistorical <- resultsHistorical %>%
  mutate(driverHomeCountry = (substr(circuit_country, 1, 3) == substr(driver_nationality, 1, 3)),
         constructorHomeCountry = (substr(circuit_country, 1, 3) == substr(constructor_nationality, 1, 3)),
         driver_nationality = NULL,
         constructor_nationality = NULL,
         circuit_country = NULL
         )


# create running total points going into race for driver and constructor and remove existing columns
resultsHistorical <- resultsHistorical %>%
  mutate(driver_preRaceTotPoints = driverStanding_runningTotalPointsInSeason - result_pointsEarned,
         constructor_preRaceTotPoints = constructorStanding_runningTotalPointsInSeason - constructorResult_pointsPerRace,
         )


# correct for inaccurate observations (i.e. negative points) caused by NAs from disqualification, failure to qualify, etc.
# 1 error in driverPoints
resultsHistorical$driver_preRaceTotPoints <- ifelse(resultsHistorical$driver_preRaceTotPoints < 0, 0, resultsHistorical$driver_preRaceTotPoints)

# ~50 errors in constructor points
resultsHistorical$constructor_preRaceTotPoints <- ifelse(resultsHistorical$constructor_preRaceTotPoints < 0, 0, resultsHistorical$constructor_preRaceTotPoints)


# remove unnecessary columns
resultsHistorical <- subset(resultsHistorical, select = -c(driverStanding_runningTotalPointsInSeason, constructorStanding_runningTotalPointsInSeason))


# create running total wins going into race for driver and constructor and remove existing columns
resultsHistorical <- resultsHistorical %>%
  mutate(driver_preRaceTotWins = ifelse(result_finishOrder == 1, driverStanding_runningTotalWinsInSeason - 1, driverStanding_runningTotalWinsInSeason),
         driverStanding_runningTotalWinsInSeason = NULL
         )

resultsHistorical <- resultsHistorical %>%
  group_by(raceId, constructor_name) %>%
  mutate(constructor_preRaceTotWins = ifelse(min(result_finishOrder) == 1, constructorStanding_runningTotalWinsInSeason - 1, constructorStanding_runningTotalWinsInSeason),
         constructorStanding_runningTotalWinsInSeason = NULL
         )


# ungroup columns
resultsHistorical <- resultsHistorical %>%
  ungroup() %>%
  as.data.frame()


# correct for inaccurate observations (i.e. negative points) caused by NAs from disqualification, failure to qualify, etc.
# >200  in constructorTotWins
resultsHistorical$constructor_preRaceTotWins <- ifelse(resultsHistorical$constructor_preRaceTotWins < 0, 0, resultsHistorical$constructor_preRaceTotWins)


# remove unnecessary columns
resultsHistorical <- subset(resultsHistorical, select = -c(raceId, constructorResult_pointsPerRace))


# create features which contain previous race results and remove current race result fields
resultsHistorical <- resultsHistorical %>%
  arrange(driver_name, race_year, race_round) %>%
  mutate(result_percentOfPreviousRaceCompleted = ifelse(driver_name == lag(driver_name) & !is.na(lag(driver_name)), lag(result_percentOfRaceCompleted), 0),
         result_previousFinishDescrip = ifelse(driver_name == lag(driver_name) & !is.na(lag(driver_name)), lag(result_finishDescription), "First race"),
         status_previousDescrip = ifelse(driver_name == lag(driver_name) & !is.na(lag(driver_name)), lag(status_description), "First race"),
         result_percentOfRaceCompleted = NULL,
         result_finishDescription = NULL,
         status_description = NULL
         )


# convert newly created columns to integers
resultsHistorical <- resultsHistorical %>%
  mutate_if(is.double, as.integer)


# convert pointsEarned to boolean
resultsHistorical <- resultsHistorical %>%
  mutate(result_inThePoints = ifelse(result_pointsEarned > 0, TRUE, FALSE),
         result_pointsEarned = NULL
  )


# arrange rows
resultsHistorical <- resultsHistorical %>%
  arrange(race_year, race_round, result_finishOrder, result_startingGridPosition)


# arrange columns
resultsHistorical <- resultsHistorical[, c("result_finishOrder", "result_inThePoints", "result_startingGridPosition", 
                                           "driver_name", "constructor_name", "circuit_name", "circuit_city", "race_month",
                                           "race_year", "race_round", "driverAge", "driverHomeCountry", "constructorHomeCountry",
                                           "result_percentOfPreviousRaceCompleted", "result_previousFinishDescrip",
                                           "status_previousDescrip", "driver_preRaceTotPoints", "constructor_preRaceTotPoints",
                                           "driver_preRaceTotWins", "constructor_preRaceTotWins")]


# remove columns due to appearing unreliable
resultsHistorical <- subset(resultsHistorical, select = -c(constructor_preRaceTotPoints, constructor_preRaceTotWins))




#### Write file ####

# define output path
path_out2 <- "./Analyzed Data"

# write to csv
write.csv(resultsHistorical, file.path(path_out2, "resultsHistorical.csv"), row.names = F)



