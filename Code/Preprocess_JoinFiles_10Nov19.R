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
# Sections are arranged in alphabetical order and contain section-specific notes

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