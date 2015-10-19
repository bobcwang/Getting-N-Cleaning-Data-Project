##--------------------------------------------------------------------------
## Author: Robert C. Wang
##--------------------------------------------------------------------------
## The purpose of this project is to demonstrate your ability to collect, 
## work with, and clean a data set. The goal is to prepare tidy data that 
## can be used for later analysis. You will be graded by your peers 
## on a series of yes/no questions related to the project. 
## You will be required to submit: 
##     1) a tidy data set as described below, 
##     2) a link to a Github repository with your script for performing 
##        the analysis, and 
##     3) a code book that describes the variables, the data, and 
##        any transformations or work that you performed to clean up 
##        the data called CodeBook.md. You should also include a README.md 
##        in the repo with your scripts. This repo explains how all of 
##        the scripts work and how they are connected.  
## 
## One of the most exciting areas in all of data science right now is 
## wearable computing - see for example this article . Companies like Fitbit, 
## Nike, and Jawbone Up are racing to develop the most advanced algorithms 
## to attract new users. The data linked to from the course website represent 
## data collected from the accelerometers from the Samsung Galaxy S smartphone. 
## A full description is available at the site where the data was obtained: 
##     
##     http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
## 
## Here are the data for the project: 
##     
##     https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
## 
## You should create one R script called run_analysis.R that does the following: 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation 
##    for each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject.
##--------------------------------------------------------------------------
## Remove all variables. Get a clean start.
##--------------------------------------------------------------------------
rm(list = setdiff(ls(), lsf.str()))

##--------------------------------------------------------------------------
## Use following libraries to reshape data frame to make tidy data frame
##--------------------------------------------------------------------------
library(plyr)
library(reshape2)

##--------------------------------------------------------------------------
## Read files from data directories & merge them with cbind()
## where the number of columns is 1 + 1 + 561 = 563
## Then merge the train and test data frame with rbind(),
## as both have the same number of columns (563)
##--------------------------------------------------------------------------
train_files <- sprintf("UCI HAR Dataset/%s/%s_%s.txt","train",c("subject","y","X"),"train")
test_files  <- sprintf("UCI HAR Dataset/%s/%s_%s.txt","test", c("subject","y","X"),"test")

data_all <- rbind(do.call("cbind", lapply(train_files, read.table)),
                  do.call("cbind", lapply(test_files, read.table)))

##--------------------------------------------------------------------------
## > train_files
## [1] "UCI HAR Dataset/train/subject_train.txt"
## [2] "UCI HAR Dataset/train/y_train.txt"      
## [3] "UCI HAR Dataset/train/X_train.txt"      
## > test_files
## [1] "UCI HAR Dataset/test/subject_test.txt" "UCI HAR Dataset/test/y_test.txt"      
## [3] "UCI HAR Dataset/test/X_test.txt"      
## > 

##--------------------------------------------------------------------------
## > dim(data_all)
## [1] 10299   563
## > data_all[1:3,c(1:4,560:563)]
##   V1 V1.1      V1.2          V2        V558       V559      V560        V561
## 1  1    5 0.2885845 -0.02029417 -0.01844588 -0.8412468 0.1799406 -0.05862692
## 2  1    5 0.2784188 -0.01641057  0.70351059 -0.8447876 0.1802889 -0.05431672
## 3  1    5 0.2796531 -0.01946716  0.80852908 -0.8489335 0.1806373 -0.04911782
## >

##--------------------------------------------------------------------------
## Get variable names from features.txt file
## Clean up the names by converting characters '(),' to '-' 
## and delete the repeated '-' characters.
## Set the data_all to descriptive names
##--------------------------------------------------------------------------
feature_names <- gsub("-$","",
                      gsub("-+","-",
                           gsub("[(),]","-",
                                read.table("UCI HAR Dataset/features.txt")[,2])))
names(data_all) <- c("Subject","Activity",feature_names)

##--------------------------------------------------------------------------
## > data_all[1:3,c(1:4,560:563)]
##   subject Activity tBodyAcc-mean-X tBodyAcc-mean-Y
## 1       1        5       0.2885845     -0.02029417
## 2       1        5       0.2784188     -0.01641057
## 3       1        5       0.2796531     -0.01946716
## angle-tBodyGyroJerkMean-gravityMean angle-X-gravityMean angle-Y-gravityMean
## 1                         -0.01844588          -0.8412468           0.1799406
## 2                          0.70351059          -0.8447876           0.1802889
## 3                          0.80852908          -0.8489335           0.1806373
## angle-Z-gravityMean
## 1         -0.05862692
## 2         -0.05431672
## 3         -0.04911782
## > 

##--------------------------------------------------------------------------
## Read activity label from file
## Then replace activity 'integer' with the label, for easy reading
##--------------------------------------------------------------------------
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]
data_all$Activity <- activity_labels[data_all$Activity]

##--------------------------------------------------------------------------
## > activity_labels
## [1] WALKING            WALKING_UPSTAIRS   WALKING_DOWNSTAIRS
## [4] SITTING            STANDING           LAYING            
## 6 Levels: LAYING SITTING STANDING WALKING ... WALKING_UPSTAIRS
## > 
## > data_all[1:3,c(1:4,560:563)]
##   Subject Activity tBodyAcc-mean-X tBodyAcc-mean-Y
## 1       1 STANDING       0.2885845     -0.02029417
## 2       1 STANDING       0.2784188     -0.01641057
## 3       1 STANDING       0.2796531     -0.01946716
##   angle-tBodyGyroJerkMean-gravityMean angle-X-gravityMean
## 1                         -0.01844588          -0.8412468
## 2                          0.70351059          -0.8447876
## 3                          0.80852908          -0.8489335
##   angle-Y-gravityMean angle-Z-gravityMean
## 1           0.1799406         -0.05862692
## 2           0.1802889         -0.05431672
## 3           0.1806373         -0.04911782
## > 

##--------------------------------------------------------------------------
## Use melt() function from library(reshape2) to change the data frame
## into a long data frame.
## melt() will take all the columns except the ones we single out 
## as id variables and put them in the same column.
## 
## Then we can use ddply() to compute mean and sd for each row,
## that is, for each combination of subject, activity and measurement
##--------------------------------------------------------------------------
melted <- melt(data_all, id.vars=c("Subject", "Activity"))
summaried <- ddply(melted, c("Subject", "Activity", "variable"), summarise,
                   mean = mean(value), sd = sd(value))
names(summaried) <- c("Subject","Activity","Feature","Avg.Measurement","SD")

##--------------------------------------------------------------------------
## > head(summaried)
##   Subject Activity         Feature Avg.Measurement        SD
## 1       1   LAYING tBodyAcc-mean-X      0.22159824 0.1689304
## 2       1   LAYING tBodyAcc-mean-Y     -0.04051395 0.1186758
## 3       1   LAYING tBodyAcc-mean-Z     -0.11320355 0.1740471
## 4       1   LAYING  tBodyAcc-std-X     -0.92805647 0.1229574
## 5       1   LAYING  tBodyAcc-std-Y     -0.83682741 0.3311775
## 6       1   LAYING  tBodyAcc-std-Z     -0.82606140 0.2885529
## > 
## > tail(summaried)
##       Subject         Activity                             Feature
## 85855      30 WALKING_UPSTAIRS  angle-tBodyAccJerkMean-gravityMean
## 85856      30 WALKING_UPSTAIRS     angle-tBodyGyroMean-gravityMean
## 85857      30 WALKING_UPSTAIRS angle-tBodyGyroJerkMean-gravityMean
## 85858      30 WALKING_UPSTAIRS                 angle-X-gravityMean
## 85859      30 WALKING_UPSTAIRS                 angle-Y-gravityMean
## 85860      30 WALKING_UPSTAIRS                 angle-Z-gravityMean
##       Avg.Measurement         SD
## 85855      0.08689401 0.42186639
## 85856     -0.03620120 0.73964131
## 85857      0.01748886 0.54026824
## 85858     -0.79011431 0.02598948
## 85859      0.24097541 0.01738028
## 85860      0.03739065 0.01800404
## >

##--------------------------------------------------------------------------
## 
##--------------------------------------------------------------------------
tidy_data <- summaried[,1:4]
write.table(tidy_data, file = "tidy_data.txt", row.name=FALSE)

##--------------------------------------------------------------------------
## > head(tidy_data)
##   Subject Activity         Feature Avg.Measurement
## 1       1   LAYING tBodyAcc-mean-X      0.22159824
## 2       1   LAYING tBodyAcc-mean-Y     -0.04051395
## 3       1   LAYING tBodyAcc-mean-Z     -0.11320355
## 4       1   LAYING  tBodyAcc-std-X     -0.92805647
## 5       1   LAYING  tBodyAcc-std-Y     -0.83682741
## 6       1   LAYING  tBodyAcc-std-Z     -0.82606140
## > 
## > tail(tidy_data)
##       Subject         Activity                             Feature
## 85855      30 WALKING_UPSTAIRS  angle-tBodyAccJerkMean-gravityMean
## 85856      30 WALKING_UPSTAIRS     angle-tBodyGyroMean-gravityMean
## 85857      30 WALKING_UPSTAIRS angle-tBodyGyroJerkMean-gravityMean
## 85858      30 WALKING_UPSTAIRS                 angle-X-gravityMean
## 85859      30 WALKING_UPSTAIRS                 angle-Y-gravityMean
## 85860      30 WALKING_UPSTAIRS                 angle-Z-gravityMean
##       Avg.Measurement
## 85855      0.08689401
## 85856     -0.03620120
## 85857      0.01748886
## 85858     -0.79011431
## 85859      0.24097541
## 85860      0.03739065
## > 

##--------------------------------------------------------------------------
## 
