### Data Cleanning Process
Had to delete urls from MySQL import as they were A) useless to predictions, and B) giving headaches

Deleted PositionText column from constructorStandings as it had the same values as Position

DOB in drivers.csv is not formatted properly, providing inconsistent dates across all fields. Cleaned DOB column for properly formatted dates

Deleted URL field from drivers.csv upon import

Names are inconsistent and needed formatting


# PositionText field within driverStandings, constructorStandings, and results files
The value of the positionText attribute is either an integer (finishing position), “R” (retired), “D” (disqualified), “E” (excluded), “W” (withdrawn), “F” (failed to qualify) or “N” (not classified).
