getwd()

# Import all files to dataframes

# read circuits file
circuits <- read.csv('./Formula 1 data/circuits.csv', sep = ",", stringsAsFactors = F)
head(circuits)

# read constructorResults file
constructorResults <- read.csv('./Formula 1 data/constructorResults.csv', sep = ",", stringsAsFactors = F)
head(constructorResults)

# read constructors file
constructors <- read.csv('./Formula 1 data/constructors.csv', sep = ",", stringsAsFactors = F)
head(constructors)

# read constructorStandings file
constructorStandings <- read.csv('./Formula 1 data/constructorStandings.csv', sep = ",", stringsAsFactors = F)
head(constructorStandings)

# read drivers file
drivers <- read.csv('./Formula 1 data/drivers.csv', sep = ",", stringsAsFactors = F)
head(drivers)

# read driverStandings file
driverStandings <- read.csv('./Formula 1 data/driverStandings.csv', sep = ",", stringsAsFactors = F)
head(driverStandings)

# read lapTimes file
lapTimes <- read.csv('./Formula 1 data/lapTimes.csv', sep = ",", stringsAsFactors = F)
head(lapTimes)

# read pitStops file
pitStops <- read.csv('./Formula 1 data/pitStops.csv', sep = ",", stringsAsFactors = F)
head(pitStops)

# read qualifying file
qualifying <- read.csv('./Formula 1 data/qualifying.csv', sep = ",", stringsAsFactors = F)
head(qualifying)

# read races file
races <- read.csv('./Formula 1 data/races.csv', sep = ",", stringsAsFactors = F)
head(races)

# read results file (most important - contains our dependent variables)
results <- read.csv('./Formula 1 data/results.csv', sep = ",", stringsAsFactors = F)
head(results)

# read seasons file
seasons <- read.csv('./Formula 1 data/seasons.csv', sep = ",", stringsAsFactors = F)
head(seasons)

# read status file
status <- read.csv('./Formula 1 data/status.csv', sep = ",", stringsAsFactors = F)
head(status)