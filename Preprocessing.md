### Data Cleaning Process
The data cleaning process was initially performed upon loading CSVs into a MySQL database for further analysis. Below is a sample of the raw data in some of the files, such as drivers:

![Raw Data - Driver name, DOB](https://github.com/PurplelinkPL/MIS-545-Project/blob/master/images/raw-data.PNG)

As shown, highlighted by red boxes in the image, this data needed to be cleaned and normalized so that it could be properly imported. The image below is the change to the data so that it is normalized:

![Clean Data - Driver name, DOB](https://github.com/PurplelinkPL/MIS-545-Project/blob/master/images/clean-data.PNG)

The names were referenced with a master list of drivers who have competed in the F1 circuit. DOB was formatted originally as DD/MM/YYYY, and was changed to MM/DD/YYYY.

#### **Below is a list of changes that were made during the MySQL merging process**

* Had to delete urls from MySQL import as they were A) useless to predictions, and B) giving headaches
* Deleted PositionText column from constructorStandings as it had the same values as Position
* DOB in drivers.csv is not formatted properly, providing inconsistent dates across all fields. Cleaned DOB column for properly formatted dates
* Deleted URL field from numerous datasets upon import
* Driver names are inconsistent and needed formatting (Done manually with a different list of all F1 drivers)

**_Note:_ lap time may need to be ignored (minutes:seconds/miliseconds) as it might affect algorithm**

### PositionText field within driverStandings, constructorStandings, and results files
The value of the positionText attribute is either an integer (finishing position), “R” (retired), “D” (disqualified), “E” (excluded), “W” (withdrawn), “F” (failed to qualify) or “N” (not classified).
