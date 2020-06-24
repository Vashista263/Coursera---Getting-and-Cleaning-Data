# run_analysis.R

# Preparing Libraries
install.packages("reshape2")
library(reshape2)


# Extracting DataSets from the web
RawDataDirectory <- "./rawData"
RawDataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
RawDataFilename <- "rawData.zip"
DestinationFile <- paste(RawDataDirectory, "/", "rawData.zip", sep = "")
DataDirectory <- "./data"

if (!file.exists(RawDataDirectory)) {
  dir.create(RawDataDirectory)
  download.file(url = RawDataURL, destfile = DestinationFile)
}

if (!file.exists(DataDirectory)) {
  dir.create(DataDirectory)
  unzip(zipfile = RawDataFilename, exdir = DataDirectory)
}


# Merging Train and Test DataSets
# Train Data
xTrain <- read.table(paste(sep = "", DataDirectory, "/UCI HAR Dataset/train/X_train.txt"))
yTrain <- read.table(paste(sep = "", DataDirectory, "/UCI HAR Dataset/train/Y_train.txt"))
sTrain <- read.table(paste(sep = "", DataDirectory, "/UCI HAR Dataset/train/subject_train.txt"))

# Test Data
xTest <- read.table(paste(sep = "", DataDirectory, "/UCI HAR Dataset/test/X_test.txt"))
yTest <- read.table(paste(sep = "", DataDirectory, "/UCI HAR Dataset/test/Y_test.txt"))
sTest <- read.table(paste(sep = "", DataDirectory, "/UCI HAR Dataset/test/subject_test.txt"))

# Merging
xData <- rbind(xTrain, xTest)
yData <- rbind(yTrain, yTest)
sData <- rbind(sTrain, sTest)


# Features
Features <- read.table(paste(sep = "", DataDirectory, "/UCI HAR Dataset/features.txt"))

# Activity Labels
ActivityLabels <- read.table(paste(sep = "", DataDirectory, "/UCI HAR Dataset/activity_labels.txt"))
ActivityLabels[,2] <- as.character(ActivityLabels[,2])

# Extracting Feature columns and Labels named "mean & std"
SelectedColumns <- grep("-(mean|std).*", as.character(Features[,2]))
SelectedColumnNames <- Features[SelectedColumns, 2]
SelectedColumnNames <- gsub("-mean", "Mean", SelectedColumnNames)
SelectedColumnNames <- gsub("-std", "Std", SelectedColumnNames)
SelectedColumnNames <- gsub("[-()]", "", SelectedColumnNames)


# Extracting Data by columns and using Descriptive Names 
xData <- xData[SelectedColumns]
AllData <- cbind(sData, yData, xData)
colnames(AllData) <- c("SUBJECT", "ACTIVITY", SelectedColumnNames)

AllData$ACTIVITY <- factor(AllData$ACTIVITY, levels = ActivityLabels[,1], labels = ActivityLabels[,2])
AllData$SUBJECT <- as.factor(AllData$SUBJECT)


# Generating a secondary independent Tidy DataSet
MeltedData <- melt(AllData, id = c("SUBJECT", "ACTIVITY"))
TidyData <- dcast(MeltedData, SUBJECT + ACTIVITY ~ variable, mean)

write.table(TidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)