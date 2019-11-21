##################################################################################################
#### Introduction ####

## Title: F1 Analysis
## Author: Tyler Campbell
## Date: Nov 2019

## IMPORTANT:
# If running full script (and not wanting to overwrite files), avoid 'Write files' section at bottom

## Description:
# This R script performs analysis of cleaned F1 source data
# Sections are arranged in alphabetical order and contain section-specific notes

##################################################################################################




#### Load packages ####

install.packages("ggplot2")
install.packages("animation")
install.packages("fpc")
install.packages("randomForest")
install.packages("corrplot")
library(dplyr)
library(VIM)

library(ggplot2)
library(animation)
library(randomForest)
library(e1071)
library(corrplot)


#### Load dataset ####
resultsHistorical <- read.csv("./Analyzed Data/resultsHistorical.csv")




#### Explore data ####

# confirm no missing values
aggr(drivers)


## K-means -----------------------------------------------------------------

# incorporate lat long of driver homes to get clusters of where they come from
# then use cluster association as new feature for prediction

# partition the data
driversLatLong <- drivers[,c(2, 6:7)]

# conert driver name to factor
driversLatLong$driver_name <- as.factor(driversLatLong$driver_name)

# standardize variables

# normalize the data - not necessary for coordinates
#driversLatLong <- driversLatLong %>%
 # mutate(lat = scale(driver_lat),
         # long = scale(driver_long)) %>%
  #select(-c(driver_lat, driver_long))


# set seed for randmozing data
set.seed(20)


# run k-means
clusters <- kmeans(driversLatLong[,c(2:3)], 4)


# inspect cluters
str(clusters)


# plot clusters (attempt multiple times if necessary)
num_clusters <- 4

driverClust <- kmeans.ani(driversLatLong[,c(2:3)], num_clusters)


# save the cluster number in the dataset as column 'driverHomeCluster'
driversLatLong <- driversLatLong %>%
  mutate(driverCluster = as.factor(clusters$cluster))


# create a function that returns the value of totwithinss, and takes inputdataset and number of clusters
# credit: Dr. Binh Zhang, The University of Arizona
kmeans.totwithinss.k <- function(dataset, number_of_centers){
  km <- kmeans(dataset, number_of_centers)
  km$tot.withinss
  }

# create a function that returns a series of totwithinss values, and takes input maxk
# vec is a vector that contains totwithinss values associated with k from 1 to maxk
# credit: Dr. Binh Zhang, The University of Arizona
kmeans.distortion <- function(dataset, maxk){
  vec <- as.vector(1:maxk)
  vec[1:maxk] <- sapply(1:maxk, kmeans.totwithinss.k, dataset = dataset)
  return (vec)
  }


# plot elbow curve
maxk <- 10

dist_vect <- kmeans.distortion(driversLatLong[,c(2:3)], maxk)

plot(1:maxk, # horizontal axis
     dist_vect, # vertical axis
     type= 'b', # curve
     col = 'blue',
     xlab = "Number of cluster",
     ylab = "Distortion"
     )


# reintroduce cluster results to resultsHistorical
driversLatLong <- subset(driversLatLong, select = -c(driver_lat, driver_long))

resultsHistorical <- resultsHistorical %>%
  left_join(driversLatLong, by = "driver_name")




#### Predict ####

## Naieve Bayes -----------------------------------------------------------------

# review the data
summary(resultsHistorical)
glimpse(resultsHistorical)

# clean dataset
resultsNB <- subset(resultsHistorical, select = -c(
  result_finishOrder,driver_lat, driver_long, constructor_lat, constructor_long)
  )

# partition data for training and testing
sample_size <- floor(0.7 * nrow(resultsNB))

training_index <- sample(nrow(resultsNB), size = sample_size, replace = FALSE)
train <- resultsNB[training_index,]
test <- resultsNB[-training_index,]


# check dimensions of partitions
dim(train)
dim(test)


# fit model
results.model <- naiveBayes(result_inThePoints ~ . , data = train)

# review model
results.model

# test model
results.predict <- predict(results.model, test, type = 'class')

# review performance
resultsNB_output <- data.frame(actual = test[,'result_inThePoints'], predicted = results.predict)

table(resultsNB_output)

TP <- 1161
FP <- 715
TN <- 4629
FN <- 921

# error rate = .2203
(FP + FN) / (TP + FP + TN + FN)
# model accuracy = .7797
(TP + TN) / (TP + FP + TN + FN)
  # conditional accuracy = .7169
  # accuracy improvement = .0628
# sensitivity = .5576
TP / (TP + FN)
# specificity = .8662
TN / (TN + FP)
# precision = .6189
TP / (TP + FP)
# false positive rate = .1338
FP / (TN + FP)


# inspect correlation of variables, which could impact model (i.e. assumed independence)
train %>%
  filter(result_inThePoints == TRUE) %>%
  select_if(is.numeric) %>%
  cor() %>%
  corrplot::corrplot()
