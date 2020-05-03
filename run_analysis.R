# Collects the whole data set for both groups and tidies the data
gettidydataset <- function() {
    library(dplyr)

    train <- readdataset("train")
    test <- readdataset("test")
    data <- bind_rows(test, train)
    
    activities <- readactivities()
    #add activity names and remove activity ids afterwards
    data <- data %>% full_join(activities) %>% select(-activityid)

    #reorder columns
    data1 <- select(data, subjectid, group, activityname)
    data2 <- select(data, -subjectid, -group, -activityname)
    data <- bind_cols(data1, data2)
}
# Calculates the means for each measurement grouped by subject and activity
# If argument is NULL, gettidydataset() is called. Otherwise it will operate
# on the handed over dataset
averages <- function(dataset) {
    if (is.null(dataset)) {
        data <- gettidydataset()
    } else {
        data <- dataset
    }
    
    #save subject to group assigments
    groupassignments <- data %>% select(subjectid, group) %>% 
        distinct() %>% arrange(subjectid)

    groupeddata <- group_by(data, subjectid, activityname)
    
    #first removing the group column, so the summarize_all function can be 
    #used (would create NAs for group column). Then the group assignments are
    #joined back into the create table
    means <- groupeddata %>% select(-group) %>% summarize_all(mean) %>% 
        full_join(groupassignments)
}

# Reads the activity tables with columns "activityid" and "activityname"
readactivities <- function() {
    columnnames <- c("activityid","activityname")
    filepath <- file.path(getwd(), "UCI HAR Dataset", "activity_labels.txt" )
    
    read.table(filepath, header=FALSE, col.names = columnnames)
}

# Reads all anonymous subjects of the study
readsubjects <- function(groupname) {
    filename <- paste0("subject_", groupname, ".txt")
    filepath <- file.path(getwd(), "UCI HAR Dataset", groupname, filename )

    read.table(filepath, header = FALSE, col.names = "subjectid")
}

# Reads the measurements for the different activities
# Only the measurements on the mean and standard deviation for each measurement
# are returned as requested by programming assignment
readx <- function(groupname) {
    filename <- paste0("X_", groupname, ".txt")
    filepath <- file.path(getwd(), "UCI HAR Dataset", groupname, filename )
    
    #read the cleaned names of features/measurements
    featurenames <- readfeaturenames()
    
    data<- read.table(filepath, header = FALSE, col.names = featurenames)
    
    #now remove all measurements not related to mean and standard deviation
    data <- data[,grepl("mean|std",colnames(data))]
}

# Reads the activities linked to the measurements in the X file
ready <- function(groupname) {
    filename <- paste0("Y_", groupname, ".txt")
    filepath <- file.path(getwd(), "UCI HAR Dataset", groupname, filename )

    read.table(filepath, header = FALSE, col.names = "activityid")
}

#read names of all the different measurements
#this character vector will be used as column names for the X readings
readfeaturenames <- function() {
    filepath <- file.path(getwd(), "UCI HAR Dataset", "features.txt" )
    
    features <- read.table(filepath, header=FALSE, colClasses = c("numeric", "character"))
    featurenames <- tolower(features[,2])
    ## remove empty brackets as they are just eating up space
    featurenames <- gsub("(\\(\\))", "", featurenames)
}

# Reads the full data set for one group
readdataset <- function(groupname) {
    subjects <- readsubjects(groupname)
    
    dataset <- cbind(subjects, ready(groupname))
    dataset <- mutate(dataset, group = groupname)
    dataset <- cbind(dataset, readx(groupname))
    tbl_df(dataset)
}

#small debug function to print details (head and str) on an oject
analyze <- function(obj) {
    print(head(obj))
    print(str(obj))
}

for (column in colnames(means)) {
    print(as.character(column[1]))
}
    