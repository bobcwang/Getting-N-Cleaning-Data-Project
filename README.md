# Coursera-Getting-n-cleaning-data-project

#### Robert C. Wang

Coursera course #3: Getting and Cleaning Data - Course Project: Reshape smartphone accelerometers data into tidy data 

## Project Assignment

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

You should create one R script called run_analysis.R that does the following. 

1. Merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement. 
1. Uses descriptive activity names to name the activities in the data set
1. Appropriately labels the data set with descriptive variable names. 
1. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

---

## Packages Used

I use 'plye' and 'reshape2' to reshape data frame to make tidy data frame.

```{r}
library(plyr)
library(reshape2)
```

## Read Data Files

The following script first defines two list of data file names:
'train_files' and 'test_files'.
The files are ordered by 

1. Subject_train.txt - This file has 1 column with subject number (range 1:30)
1. y_train.txt - This file has 1 column with activity number (range 1:6)
1. X_train.txt - This file has 561 columns with measurement values

where all three files have the same row numbers.
The 'test' data files are organized the same way.

It then read and merge the data files:

1. Read the 'train_files' and merge them with cbind() function 
1. Read the 'test_files' and merge them with cbind() function 
1. Merge the above data frames with rbind() function

```{r}
train_files <- sprintf("UCI HAR Dataset/%s/%s_%s.txt","train",c("subject","y","X"),"train")
test_files  <- sprintf("UCI HAR Dataset/%s/%s_%s.txt","test", c("subject","y","X"),"test")

data_all <- rbind(do.call("cbind", lapply(train_files, read.table)),
                  do.call("cbind", lapply(test_files, read.table)))
```

Read files from data directories & merge them with cbind()
where the number of columns is 1 + 1 + 561 = 563
Then merge the train and test data frame with rbind(),
as both have the same number of columns (563)



