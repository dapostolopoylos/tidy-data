## Codebook for the Coursera "Getting and Cleaning Data" course project


This is a data dictionairy for the Coursera *"Getting and Cleaning Data"* course project.

---

#### Data Set Description

The original raw data for the course can be downloaded from the following url: 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

A full description of the data can be found in the follwing url: 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The "Human Activity Recognition Using Smartphones Data Set" consists of observations from the recordings of 30 subjects performing activities of daily living (ADL) while 
carrying a waist-mounted smartphone with embedded inertial sensors. The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. 
Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. 
Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been 
video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the 
training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap 
(128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body 
acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. 
From each window, a vector of features was obtained by calculating variables from the time and frequency domain. 


### Transformations

Aditional packages used: dplyr, sqldf

The data analysis consists of the following steps:

1. Read into R the files that concern the *test* dataset

    ```
    testData <- read.table("./UCI_HAR_Dataset/test/X_test.txt") ##(experiment observations)
    
    subjectTest <- read.table("./UCI_HAR_Dataset/test/subject_test.txt") ##(subjects)
    
    activitiesTest <- read.table("./UCI_HAR_Dataset/test/y_test.txt") ##(activities)
    ```

2. Read into R the files that concern the *train* dataset

    ```
    trainData <- read.table("./UCI_HAR_Dataset/train/X_train.txt") ##(experiment observations)
    
    subjectTrain <- read.table("./UCI_HAR_Dataset/train/subject_train.txt") ##(subjects)
    
    activitiesTrain <- read.table("./UCI_HAR_Dataset/train/y_train.txt") ##(activities)
    ```

3. Merge the *test*, *subject_test* and *activitiesTest* data sets by column in order to combine measures with each subject and each activity

    ```
    testData <- cbind(testData,subjectTest,activitiesTest)
    ```    
3. Do the same for *train*, *subject_train* and *activitiesTrain* data sets:

    ```
    trainData <- cbind(trainData,subjectTrain,activitiesTrain)
    ```    
4. Get column names from *"features.txt"* and store them in a vector.Do all the necessary cleansing on the variable names.Add the *"subject"* column and the *"activityCode"* column  in the *namesVector*

    ```
    colNames <- read.table("./UCI_HAR_Dataset/features.txt")
    namesVector <- as.vector(colNames$V2)
    namesVector <- gsub("\\(\\)", "",namesVector)
    namesVector <- gsub("-","_",namesVector)
    namesVector <- append(namesVector,c("subject","activityCode"))
    ```

5. Use the *namesVector* to rename the columns of the test and train datasets
    
    ```
    names(testData) <- namesVector
    names(trainData) <- namesVector
    ```
6. Clip the two datasets together

    ```
    mergeData <- rbind(testData,trainData) 
    ```
7. Remove columns with duplicated names

    ```
    mergeData <- mergeData[!duplicated(names(mergeData))]
    ```
8. Read the *"activity_labes.txt"* file

    ```
    activityLabels <- read.table("./UCI_HAR_Dataset/activity_labels.txt")
    names(activityLabels) <- c("activityCode","activity")
    ```
    
9. Join the *activityLabels* data set with the *mergeData* data set in order to get labels of the activities 

    ```
    mergeData <- sqldf("select mergeData.*, activityLabels.activity from mergeData left outer join activityLabels on mergeData.activityCode = activityLabels.activityCode")
    ```
    
10. Create a new dataset containing only the **mean()** and **std()** columns

    ```
    measuresDS <- select(mergeData,matches("mean|std()",ignore.case=FALSE))
    measuresDS <- select(measuresDS,-matches("Freq()"))
    ```

11. Create a temp label set in order to cbind it later on the final measures data set

    ```
    labelsTmp <- select(mergeData,subject,activity)
    ```
    
12. Merge the *measuresDS* and *labelsTmp* data sets by column

    ```
    measuresDS <- cbind(measuresDS,labelsTmp)
    ```
    
13. Create the grouped by subject and activity dataset in order to get the final summarised and tidy data set

    ```
    groupedDS <- group_by(measuresDS,subject,activity)
    varNames <- colnames(measuresDS)
    varNames <- varNames[which (varNames != "activity" & varNames != "subject")]
    varNames2 <- lapply(varNames,as.symbol)
    ```
14. Loop through the colnames of the *measuresDS* and create the final data set column by column

    ```
    for (name in varNames2){
        if (name==varNames2[1]) {
            res<-summarise(groupedDS, name = mean(name))
        }
        else {
                tmp<-summarise(groupedDS, name = mean(name))
                res<-cbind(res,tmp[,3])
        }
    }
    ```
    
15. Create the column names of the final tidy data set *res*

    ```
    varNames<-c(c("subject","activity"),varNames)
    names(res)<-varNames
    ```
    
16. Export the final tidy data set in txt format

    ```
    write.table(res,file="./tidy_ds_with_average_values.txt",row.names = FALSE,quote=FALSE,append=FALSE, sep="\t")
    ```

### Variables

This is description from the *"features_info.txt"* file that describes the features selected from the database for the analysis:

```
The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz.

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.
```

All the measure variables of the final data set can be described according to this description from the *"features_info.txt"* file.  

The final tidy data set called *"res"* from which is exported the *"tidy_ds_with_average_values.txt"* consists of the following variables:

1. subject
    * Takes values from 1 to 30. It's an id for every subject that has participated in the experiment.
2. activity
    * It's a label of every kind of activity
        * 1 WALKING
        * 2 WALKING_UPSTAIRS
        * 3 WALKING_DOWNSTAIRS
        * 4 SITTING
        * 5 STANDING
        * 6 LAYING
3. tBodyAcc_mean_X
    * Takes numeric values
4. tBodyAcc_mean_Y
    * Takes numeric values
5. tBodyAcc_mean_Z
     * Takes numeric values
6. tBodyAcc_std_X
     * Takes numeric values
7. tBodyAcc_std_Y
     * Takes numeric values
8. tBodyAcc_std_Z
     * Takes numeric values
9. tGravityAcc_mean_X
     * Takes numeric values
10. tGravityAcc_mean_Y
     * Takes numeric values
11. tGravityAcc_mean_Z
     * Takes numeric values
12. tGravityAcc_std_X
     * Takes numeric values
13. tGravityAcc_std_Y
     * Takes numeric values
14. tGravityAcc_std_Z
     * Takes numeric values
15. tBodyAccJerk_mean_X
     * Takes numeric values
16. tBodyAccJerk_mean_Y
     * Takes numeric values
17. tBodyAccJerk_mean_Z
     * Takes numeric values
18. tBodyAccJerk_std_X
     * Takes numeric values
19. tBodyAccJerk_std_Y
     * Takes numeric values
20. tBodyAccJerk_std_Z
     * Takes numeric values
21. tBodyGyro_mean_X
     * Takes numeric values
22. tBodyGyro_mean_Y
     * Takes numeric values
23. tBodyGyro_mean_Z
     * Takes numeric values
24. tBodyGyro_std_X
     * Takes numeric values
25. tBodyGyro_std_Y
     * Takes numeric values
26. tBodyGyro_std_Z
     * Takes numeric values
27. tBodyGyroJerk_mean_X
     * Takes numeric values
28. tBodyGyroJerk_mean_Y
     * Takes numeric values
29. tBodyGyroJerk_mean_Z
     * Takes numeric values
30. tBodyGyroJerk_std_X
     * Takes numeric values
31. tBodyGyroJerk_std_Y
     * Takes numeric values
32. tBodyGyroJerk_std_Z
     * Takes numeric values
33. tBodyAccMag_mean
     * Takes numeric values
34. tBodyAccMag_std
     * Takes numeric values
35. tGravityAccMag_mean
     * Takes numeric values
36. tGravityAccMag_std
     * Takes numeric values
37. tBodyAccJerkMag_mean
     * Takes numeric values
38. tBodyAccJerkMag_std
     * Takes numeric values
39. tBodyGyroMag_mean
     * Takes numeric values
40. tBodyGyroMag_std
     * Takes numeric values
41. tBodyGyroJerkMag_mean
     * Takes numeric values
42. tBodyGyroJerkMag_std
     * Takes numeric values
43. fBodyAcc_mean_X
     * Takes numeric values
44. fBodyAcc_mean_Y
     * Takes numeric values
45. fBodyAcc_mean_Z
     * Takes numeric values
46. fBodyAcc_std_X
     * Takes numeric values
47. fBodyAcc_std_Y
     * Takes numeric values
48. fBodyAcc_std_Z
     * Takes numeric values
49. fBodyAccJerk_mean_X
     * Takes numeric values
50. fBodyAccJerk_mean_Y
     * Takes numeric values
51. fBodyAccJerk_mean_Z
     * Takes numeric values
52. fBodyAccJerk_std_X
     * Takes numeric values
53. fBodyAccJerk_std_Y
     * Takes numeric values
54. fBodyAccJerk_std_Z
     * Takes numeric values
55. fBodyGyro_mean_X
     * Takes numeric values
56. fBodyGyro_mean_Y
     * Takes numeric values
57. fBodyGyro_mean_Z
     * Takes numeric values
58. fBodyGyro_std_X
     * Takes numeric values
59. fBodyGyro_std_Y
     * Takes numeric values
60. fBodyGyro_std_Z
     * Takes numeric values
61. fBodyAccMag_mean
     * Takes numeric values
62. fBodyAccMag_std
     * Takes numeric values
63. fBodyBodyAccJerkMag_mean
     * Takes numeric values
64. fBodyBodyAccJerkMag_std
     * Takes numeric values
65. fBodyBodyGyroMag_mean
     * Takes numeric values
66. fBodyBodyGyroMag_std
     * Takes numeric values
67. fBodyBodyGyroJerkMag_mean
     * Takes numeric values
68. fBodyBodyGyroJerkMag_std
     * Takes numeric values