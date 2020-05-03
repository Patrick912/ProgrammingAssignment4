---
title: "README.md"
author: "Patrick Neumann"
date: "5/2/2020"
---
## Programming Assignment 4

The R file `run_analysis.R` contains all scripts to perform the data
analysis for this assignment.

There are two main function for the user to call

- `gettidydataset()`
- `averages(dataset)`

See details below.

### `gettidydataset()`
The script assumes that the original folder structure of the data set is
retained and the data is placed directly in the current workind directory, e.g.
all data is in the subfolder *UCI HAR Dataset*.

`gettidydataset()` will call the `readdataset(groupname)` function for both groups/sets 
(train and test)and will row bind the sets together.
After that it will read the activity labels from activity_labels.text, merge the
resulting table with the complete dataset based on the activityid column and
last drop the activityid column, so only the activity names remain.

### `averages(dataset)`
This function calculates the means for each measurement grouped by subject and 
activity. If argument is NULL, `gettidydataset()` is called. Otherwise it will 
operate on the handed over dataset assuming it is a tidy data set.

#### `readdataset(groupname)`
This function reads all data for a given group and is called by the 
`gettidydataset()` function. For this it first reads all the subjects and column 
binds this data with the performed activities from the Y-file.
After that a new column with the group identifies is added, so the information
about the groups is retained. In a last step the measurements from the X-file
are column bound to the data set.

#### `readx(groupname)`
This function is called by the `readdataset(groupname)` function and reads all the
measurement data from the X-file.
Before doing so the measurement names for the column names are retrieved from the
`readfeaturenames()` function.
In a last step all measurements (columns) not pertaining to a mean or standard
deviation value are dropped.

#### `readfeaturenames()`
This function is called by the `readx(groupname)` function and reads all the
measurement names from the features file.
The names are cleaned by making all characters lower case and by dropping and
any empty brackets ("()").