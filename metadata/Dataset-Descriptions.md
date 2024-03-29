  
**This file contains descriptions and processing considerations for
source data.**  
  

##### F1 Data (<a href="https://www.kaggle.com/cjgdev/formula-1-race-data-19502017" class="uri">https://www.kaggle.com/cjgdev/formula-1-race-data-19502017</a>)

-   **circuits:** every circuit name, location, and wiki page url

-   **constructorResults:** aggregated constructor points earned per
    race
    -   ‘D’ in ‘status’ column represents ‘Disqualified’ due to Spygate
        scandal in 2007 season
        (<a href="https://en.wikipedia.org/wiki/2007_Formula_One_espionage_controversy" class="uri">https://en.wikipedia.org/wiki/2007_Formula_One_espionage_controversy</a>)
-   **constructors:** every constructor name, nationality, and wiki page
    url
    -   constructors are teams (e.g. Ferrari, Williams, Red Bull, etc.)
    -   in modern racing era there are 10 constructors with 2 drivers
        each
-   **constructorStandings:** running/accumulated ‘points’ and ‘wins’
    for constructors in a given season

-   **drivers:** every driver name, number, dob, nationality, and wiki
    page url
    -   create feature that contains driver age at time of race
-   **driverStandings:** accumulated driver points and wins for a given
    season
    -   thought: if you could associate a race with its round \#, then
        driver with most points after final round wins championship
-   **lapTimes:** lap time and position for each driver in each lap of
    each race
    -   file is missing lap times from at least races 400-800 (by
        raceID)
    -   consider excluding lap 25 of raceId 847 (2011 Canadian Grand
        Prix had “torrential rains” that caused a single lap to clock in
        at over 2 hrs)
    -   consider excluding file altogether
-   **pitStops:** stop number and stop duration/milliseconds of each
    pitstop at a given time of day on a given lap by a given driver
    -   file excludes races before 2011 and after 2017
    -   consider aggregating ‘milliseconds’ per driver per race to
        obtain a single total pit time per race
    -   consider obtaining largest number of ‘stop’ per driver per race
        to get total number of pit stops per race
    -   consider excluding file altogether
-   **qualifying:** qualifying times (and final qualifying position) for
    each driver of each race
    -   the process of qualifying determines grid position at start of
        race
    -   the slowest drivers (e.g. bottom 5) get knocked out after each
        round of qualifying
    -   ‘position’ should be the same as grid in results file
    -   consider excluding file altogether because of NAs
-   **races:** race name, date, and time for each seasons, and wiki page
    url
    -   race time is empty from 1950 to 2005
    -   consider removing ‘time’
    -   remove ‘name’ which will be redundant after merge (circuits
        table contains ref)
-   **results:** results of every race (*critical file containing
    dependent variables*)
    -   ‘time’ is inconsistently represented as minutes:seconds beyond 1
        hr for first place driver, then the gap for next several drivers
    -   no time is recorded for racers greater than 1 lap behind the
        winner
    -   consider just including ‘time’ for winner, otherwise it’s
        reflected as “gap” and often +1 laps rather than a time
    -   ‘position’ = raceFinish, ‘positionText’ = raceFinish or
        descriptor of retired/disqualified etc., ‘positionOrder’ =
        raceFinish or order of retired/disqualified
    -   positionText: D=Disqualified, E=Excluded, F=Did Not (/failed to)
        Qualify, N=Not Classified, R=Retired, W=Withrew
    -   consider converting ‘positionText’ to boolean (i.e. Finished,
        Did not finish)
    -   fastest lap data is empty or NA from 1950 to 2004
    -   ‘grid’ is mostly a duplicate of position in qualifying table,
        but is likely more reliable
-   **seasons:** year and wiki page url of each season
    -   somewhat irrelevant file unless wanting to scrape wiki pages
-   **status:** key and description of race results (e.g. finished, +1
    Lap, collision, etc.)
