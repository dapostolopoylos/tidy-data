# Load requested libraries
library(dplyr)
library(sqldf)

# Read the test, subject_test and activities datasets
testData <- read.table("./UCI_HAR_Dataset/test/X_test.txt")
subjectTest <- read.table("./UCI_HAR_Dataset/test/subject_test.txt")
activitiesTest <- read.table("./UCI_HAR_Dataset/test/y_test.txt")

# Merge the test, subject_test and activitiesTest data sets by column in order to combine 
# measures with each subject and each activity
testData <- cbind(testData,subjectTest,activitiesTest)

# Read the train and subject_train datasets
trainData <- read.table("./UCI_HAR_Dataset/train/X_train.txt")
subjectTrain <- read.table("./UCI_HAR_Dataset/train/subject_train.txt")
activitiesTrain <- read.table("./UCI_HAR_Dataset/train/y_train.txt")

# Merge the train, subject_train and activitiesTrain data sets by column in order to combine 
# measures with each subject and each activity
trainData <- cbind(trainData,subjectTrain,activitiesTrain)

# Delete unnecessary objects
rm(subjectTest,activitiesTest,subjectTrain,activitiesTrain)

# Get column names from features.txt and store them in a vector.
# Do all the necessary cleansing on the variable names
# Add the "subject" column and the "activityCode" column  in the namesVector 
colNames <- read.table("./UCI_HAR_Dataset/features.txt")
namesVector <- as.vector(colNames$V2)
namesVector <- gsub("\\(\\)", "",namesVector)
namesVector <- gsub("-","_",namesVector)
namesVector <- append(namesVector,c("subject","activityCode"))

# Use the namesVector to rename the columns of the test and train datasets
names(testData) <- namesVector
names(trainData) <- namesVector

# Clip the two datasets together
mergeData <- rbind(testData,trainData)

# Delete unnecessary objects
rm(colNames,namesVector,testData,trainData)

# Remove columns with duplicated names
mergeData <- mergeData[!duplicated(names(mergeData))]

# Read the activity_labes file
activityLabels <- read.table("./UCI_HAR_Dataset/activity_labels.txt")
names(activityLabels) <- c("activityCode","activity")

# Join the activityLabels data set with the mergeData data set in order to get labes of the activities 
mergeData <- sqldf("select mergeData.*, activityLabels.activity from mergeData left outer join activityLabels on mergeData.activityCode = activityLabels.activityCode")

# Create a new dataset containing only the mean() and std() columns
measuresDS <- select(mergeData,matches("mean|std()",ignore.case=FALSE))
measuresDS <- select(measuresDS,-matches("Freq()"))

# Create a temp label set in order to cbind it later on the final measures data set
labelsTmp <- select(mergeData,subject,activity)

# Merge the measuresDS and labelsTmp data sets by column 
measuresDS <- cbind(measuresDS,labelsTmp)

# Delete unnecessary objects
rm(activityLabels,labelsTmp,mergeData)

# Create the grouped by subject and activity dataset 
# in order to get the final summarised and tidy data set
groupedDS <- group_by(measuresDS,subject,activity)

varNames <- colnames(measuresDS)
varNames <- varNames[which (varNames != "activity" & varNames != "subject")]
varNames2 <- lapply(varNames,as.symbol)

# Loop through the colnames of the measuresDS and create the final data set column by column
for (name in varNames2){
  if (name==varNames2[1]) {
        res<-summarise(groupedDS, name = mean(name))
  }
  else {
        tmp<-summarise(groupedDS, name = mean(name))
        res<-cbind(res,tmp[,3])
  }
}

# Create the column names of the final tidy data set res
varNames<-c(c("subject","activity"),varNames)
names(res)<-varNames

# Export the final tidy data set in txt format
write.table(res,file="./tidy_ds_with_average_values.txt",row.names = FALSE,quote=FALSE,append=FALSE)

# Delete unnecessary objects
rm(groupedDS,tmp,measuresDS,name,varNames,varNames2)