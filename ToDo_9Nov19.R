########
# To-do:
########
## Before Binding ##

# re-order columns as needed

# lapTimes and pitTimes may need to be converted back to just data.frame type
# check for outliers
# write each individual file to new fileName_clean.csv in "Formula 1 Data" directory or new directory
# commit to github (once after initial pass-through and again after final tidying)
# create new Rscript for merging
# review that NAs were handled and inserted correctly
# ensure all variables are of correct types
# rename folder on github to source data - raw, and then create a new folder 'processed' data, also 'analyzed', 'figures', etc.

## After Binding##

# remove Id columns
# cremove the ungroup() function in lapTimes and pitTimes that groups by raceId and driverId
# convert variables to appropriate types if necessary (e.g. factor)
# more feature creation (e.g. driver age at time of race, distance of race from home, etc.)
# commit to github