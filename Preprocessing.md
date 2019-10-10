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
