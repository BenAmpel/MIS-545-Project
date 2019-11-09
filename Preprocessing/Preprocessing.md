### Data Cleaning Process
The data cleaning process was initially performed upon loading CSVs into a MySQL database for further analysis. Below is a sample of the raw data in some of the files, such as drivers:

![Raw Data - Driver name, DOB](https://github.com/PurplelinkPL/MIS-545-Project/blob/master/images/raw-data.PNG)

As shown, highlighted by red boxes in the image, this data needed to be cleaned and normalized so that it could be properly imported. The image below is the change to the data so that it is normalized:

![Clean Data - Driver name, DOB](https://github.com/PurplelinkPL/MIS-545-Project/blob/master/images/clean-data.PNG)

The names were referenced with a master list of drivers who have competed in the F1 circuit. DOB was formatted originally as DD/MM/YYYY, and was changed to MM/DD/YYYY.

* PositionOrder was reduced to 5, to limit the driver place finishers to the top 5 placewinners for each race.

* PositionOrder was changed to RaceFinish, since it signifies the place finish for the drivers per race.

* Race time had 14 distinct categories, with 12:00:00 being the value for more than 50% of the data fields. Race time was then binned to "Morning", "Noon", and "Afternoon", with Morning consisting of each race time before 12:00, Noon being exactly 12:00, and Afternoon being any race time after 12:00.

* Since the positionOrder was limited to only those in the top 5, Status column was removed because more than 95% of the drivers who finish in the top 5 finished the race, the other value was "+1", indicating that the driver was lapped and finished the race in the next lap behind the leading placewinners.

* Car number was removed since it is irrelevant in predicting who wins a race.

* Driver forename and surname is concatenated to produce a driverName.

* Driver Date of Birth was changed to driver age at the time of the race, and then subsequently removed.

* FastestLap and LapRank entail what lap the driver had their fastest time on, and what rank among the drivers they were. For example, a driver could have their fastest lap on lap 44 and could be in 4th place at that time. Due to the redundancy and number of categories, these two fields were removed.

* Laps signifies the number of laps per race per track, and was removed since it is duplicated. RaceLap is used in place of Laps since it distributes lap time and other attributes incrementally for each race.

* Laptime was removed since it contained total race time, in addition to individual lap time, and skewed the data.



#### **Below is a list of changes that were made during the MySQL merging process**

* Had to delete urls from MySQL import as they were A) useless to predictions, and B) giving headaches
* Deleted PositionText column from constructorStandings as it had the same values as Position
* DOB in drivers.csv is not formatted properly, providing inconsistent dates across all fields. Cleaned DOB column for properly formatted dates
* Deleted URL field from numerous datasets upon import
* Driver names are inconsistent and needed formatting (Done manually with a different list of all F1 drivers)
* After complete merge, 70 columns remained. That was immediately reduced to 25 based on hand selected feature selection
* Columns that were deleted included Primary key columns, duplicates, data known to be bad predictors (e.g. lat, long, driver number), data that was highly dependant (e.g. driver points compared to driver position)

**_Note:_ lap time may need to be ignored (minutes:seconds/miliseconds) as it might affect algorithm**

### PositionText field within driverStandings, constructorStandings, and results files
The value of the positionText attribute is either an integer (finishing position), “R” (retired), “D” (disqualified), “E” (excluded), “W” (withdrawn), “F” (failed to qualify) or “N” (not classified).

### Random Ideas for Data Transformation I'm getting from MIS 584 - Big Data
##### Can probably wait to be implemented until end of project, if at all - Ben
* Principal Component Analysis: Dimensionality Reduction based on variance
* Heuristic Search: Not used as much anymore thanks to deep learning, but could be could for this project to select best features (needs all tested variables to be continuous however)
* One-Hot Encoding: For any categorical variables we have with less than 5 possible values
* Categorical Embedding
* Feature Creation
* Normalization: Min-Max, Z-Score, Decimal Scaling, Bins / Logarithmic: For continuous variables we have with a huge range of values (milliseconds for lap time maybe)
