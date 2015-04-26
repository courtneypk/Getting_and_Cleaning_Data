# Load the libraries that will be needed for the code
library(plyr)
library(dplyr)
library(reshape2)
library(readr)
# Set up the paths for files to be read in
wd <- getwd()
projDir <- paste(wd, "/Project/UCI HAR Dataset", sep="")
testDataDir <- paste(projDir, "/test", sep="")
trainDataDir <- paste(projDir, "/train", sep="")

# Read in the Test and Train data
xTestFile <- paste(testDataDir, "/X_test.txt", sep="")
xTestData <- read_fwf(xTestFile, fwf_empty(xTestFile))

xTrainFile <- paste(trainDataDir, "/X_train.txt", sep="")
xTrainData <- read_fwf(xTrainFile, fwf_empty(xTrainFile))

allData <- rbind(xTrainData, xTestData) # Stack the Training data on top of the Test data.

# Get the Subject IDs for the Test and Train datasets and combine them
subjectTestIdFile <- paste(testDataDir, "/subject_test.txt", sep="")
subjectTestId <- read_lines(subjectTestIdFile, n = -1) # Subject ids for the Test dataset

subjectTrainIdFile <- paste(trainDataDir, "/subject_train.txt", sep="")
subjectTrainId <- read_lines(subjectTrainIdFile, n = -1) # Subject ids for the Train dataset

subjectId <- as.data.frame(c(subjectTrainId, subjectTestId)) # as data frame
names(subjectId) <- c("Subject_Id")

# The activity codes are contained in the Y_test.txt and Y_train.txt files 
yTestFile <- paste(testDataDir, "/Y_test.txt", sep="")
yTestData <- read_lines(yTestFile, n = -1)

yTrainFile <- paste(trainDataDir, "/Y_train.txt", sep="")
yTrainData <- read_lines(yTrainFile, n = -1)

activityCodes <- as.data.frame(c(yTrainData, yTestData)) # as data frame
names(activityCodes) <- c("Activity_Codes") # Give this column a meaningful title


# This reads in the Activity Codes and their Labels; this will be used later to provide clarify in the tidy result
activityLabelsFile <- paste(projDir, "/activity_labels.txt", sep="")
activityLabels <- read_delim(activityLabelsFile, delim = " ", col_names = FALSE)
names(activityLabels) <- c("Activity_Codes", "Activity")

# Read in the 561 feature variable names using read_delim:
allFeaturesFile <- paste(projDir, "/features.txt", sep="")
allFeatures <- read_delim(allFeaturesFile, delim = " ", col_names = FALSE)

allFeatures$X1 <- NULL # Remove the first column of indices and leave just the text
allFeatures_df <- as.data.frame(allFeatures) # then get the data frame out of the data frame tbl.
allFeatures_v <- as.vector(allFeatures_df[,1]) # Make this a vector now, not a data frame.
allFeaturesMod <- gsub("\\(\\)", "", allFeatures_v) # Remove all instances of "()" since this does not make a valid column name

# Now identify just those features that are means and standard deviations, the variables of interest,
# and put the indices where these features are located into the vector "means.stds". This will be 
# used to select just the columns and the column names desired from the full dataset.
means <- grep("mean", allFeaturesMod)
stds <- grep("std", allFeaturesMod)

# Collect indices into the sorted vector "means.stds" for the features that include either "mean" or "std". 
# "Mean" was left out since that variable is really a measurement of an angle between two other variables.
means.stds <- sort(c(means, stds)) 
featureNames <- allFeaturesMod[means.stds] # Now select just the feature names desired into featureNames
featureNamesModified <- gsub("([a-z])([A-Z])", "\\1-\\2", featureNames) # Here, use the camelCase to help separate the terms
featureNamesModified2 <- gsub("^f-", "Freq-", featureNamesModified)
featureNamesFinal <- gsub("^t-", "Time-", featureNamesModified2)

# Now select just the columns of interest from the data frame allData, based on the vector of column indices "means.stds"
mean.std.Data <- allData[means.stds]
names(mean.std.Data) <- featureNamesFinal

# We will now use cbind to bring together the SubjectId, ActivityCode and the 79 features
wide <- cbind(subjectId, activityCodes, mean.std.Data)
# Use melt to get the Features all in one column
melted <- melt(wide, id=c("Subject_Id", "Activity_Codes"))

# Now we go through a series of steps to get the data finalized into a tidy form
bySubjectActivity <- wide %>% group_by(Subject_Id, Activity_Codes) # This gets the data ordered for the next step
almostTidyData <- bySubjectActivity %>% summarise_each(funs(mean)) # This is where the means for each grouping of Subject_Id and Activity_Codes is calculated for summary 
nearlyTidyData <- merge(almostTidyData, activityLabels, by = intersect(names(almostTidyData), names(activityLabels))) # Get the Descriptive terms for activities into the dataset
periTidyData <- mutate(nearlyTidyData, Subject_ID = as.numeric(Subject_Id)) # Use mutate to create a numeric Subject_ID from the factor Subject_Id in order to order the dataset

tidyData <- periTidyData[c(83, 82, 3:81)] # Now pick up the numeric Subject_ID and the more descriptive Activities and drop the first two columns

tidyData <- tidyData %>% arrange(Subject_ID, Activity) # Finally, reorder the dataset by Subject_ID and Activity

write.table(tidyData, file = "tidyData.txt", row.name = FALSE)
