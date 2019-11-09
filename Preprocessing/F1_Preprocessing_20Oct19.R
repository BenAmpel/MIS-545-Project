getwd()

# Import all files

# read circuits file
circuits <- read.csv('./Formula 1 data/circuits.csv', stringsAsFactors = F)
head(circuits)
# remove columns: 'alt', 'lat', 'long'

# read constructorResults file
constructorResults <- read.csv('./Formula 1 data/constructorResults.csv', stringsAsFactors = F)
head(constructorResults)
# provides aggregated constructor points per race
# most likely redundant

# read constructors file
constructors <- read.csv('./Formula 1 data/constructors.csv', stringsAsFactors = F)
head(constructors)
# remove column: 'x'

# read constructorStandings file
constructorStandings <- read.csv('./Formula 1 data/constructorStandings.csv', stringsAsFactors = F)
head(constructorStandings)
# records accumulated 'points' and 'wins' for a given season
# remove column: 'x'

# read drivers file
drivers <- read.csv('./Formula 1 data/drivers.csv', stringsAsFactors = F)
head(drivers)
# concatenate 'forename' & 'surname' into one field
# remove column: 'number'

# read driverStandings file
driverStandings <- read.csv('./Formula 1 data/driverStandings.csv', stringsAsFactors = F)
head(driverStandings)
# records accumulated 'points' and 'wins' for a given season
# if you could associate a race with its round #, then driver with most points at final round wins championship

# read lapTimes file
lapTimes <- read.csv('./Formula 1 data/lapTimes.csv', stringsAsFactors = F)
head(lapTimes)
# time = milliseconds
# consider excluding file altogether

# read pitStops file
pitStops <- read.csv('./Formula 1 data/pitStops.csv', stringsAsFactors = F)
head(pitStops)
# consider aggregating 'milliseconds' per driver per race to obtain a single total pit time
# obtain largest number of 'stop' per driver per race to get total number of pit stops

# read qualifying file
qualifying <- read.csv('./Formula 1 data/qualifying.csv', stringsAsFactors = F)
head(qualifying)
# remove column: 'number'
# consider excluding file altogether

# read races file
races <- read.csv('./Formula 1 data/races.csv', stringsAsFactors = F)
head(races)
# races$time is empty from 1950 to 2005
# consider removing 'time' and keep 'round' and/or 'date' instead which is more complete

# read results file (most important - contains our dependent variables)
results <- read.csv('./Formula 1 data/results.csv', stringsAsFactors = F)
head(results)
# consider just including 'time' for winner, otherwise it's reflected as "gap" and often +1 laps rather than a time
# 'position' = raceFinish, 'positionText' = raceFinish or descriptor of retired/disqualified, 'positionOrder' = raceFinish or order of retired/disqualified
# definitely include 'grid'

# read seasons file
seasons <- read.csv('./Formula 1 data/seasons.csv', stringsAsFactors = F)
head(seasons)
# somewhat irrelevant file unless wanting to scrape wiki pages

# read status file
status <- read.csv('./Formula 1 data/status.csv', stringsAsFactors = F)
head(status)