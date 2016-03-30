# Requirements
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
# each variable for each activity and each subject.

library(dplyr)
library(tidyr)
library(data.table)

datadir <- "UCI HAR Dataset"

# load a data set from disk. don't want to combine all columns here so I can subset by colNum later
# want to be able to load few rows from data during development and initial testing phase
read_data_fileset <- function(data_set = "test", proto = T) {
  nrows <- if (proto) 10 else -1
  data <- read.table(file.path(datadir, data_set, paste("X_" , data_set, ".txt", sep = "")), nrows = nrows)
  activity <- read.table(file.path(datadir, data_set, paste("y_", data_set, ".txt", sep = "")), col.names = "ActivityId", nrows = nrows)
  subject <- read.table(file.path(datadir, data_set, paste("subject_", data_set, ".txt", sep = "")), col.names = "SubjectId", nrows = nrows)
  list(data=data, activity=activity, subject=subject)
}

# only want those features with mean or std in name
# remove unwanted columns from data frame
process_data <- function(data) {
  features <- read.table( file.path(datadir, "features.txt"), col.names = c("Index", "Name"))
  req_features <- filter(features, grepl("mean\\(|std\\(", Name))
  data <- data[,req_features$Index]
  # 4. Appropriately labels the data set with descriptive variable names.
  # set descriptive col names
  names(data) <- req_features$Name
  data
}

# create a summary of means
create_summary <- function(data) {
  as.data.table(data) %>%
    # set grouping
    group_by(ActivityName, SubjectId, Feature) %>%
    # calculate means
    summarise_each(funs(mean(., na.rm=TRUE))) %>%
    # sort
    arrange(ActivityName, SubjectId) %>%
    # rename column
    rename(MeanAverage = Value)
}

save_file <- function(data) {
  write.table(data, "tidy_summary_output.csv", row.names = F, sep=",")
}

# run data processing
run <- function(proto = T) {
  # load test data sets
  test <- read_data_fileset("test", proto)
  # load train data sts
  train <- read_data_fileset("train", proto)

  # load activity descriptions
  activities <- read.table( file.path(datadir, "activity_labels.txt"), col.names = c("ActivityId", "ActivityName"))
  
  # 1. Merge the training and test sets
  data <- rbind(test$data, train$data)
  activity <- rbind(test$activity, train$activity)
  subject <- rbind(test$subject, train$subject)
  
  # 2. Extract only the measurements on the mean and standard deviation for each measurement.
  data %>% 
    process_data() %>%
    # 3. Use descriptive activity names to name the activities in the data set
    # combine the test data, activity identifiers and subject identifiers
    cbind(activity, subject) %>%
    # map activity id to activity description
    merge(activities) %>%
    select(-ActivityId) %>%
    gather("Feature", "Value", -SubjectId, -ActivityName, factor_key = TRUE) 
  #%>%
    # 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
    # each variable for each activity and each subject.
    #create_summary() %>%
    # save file to local disk
    #save_file()
}
