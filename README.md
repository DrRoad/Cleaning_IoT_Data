# Overview

This is a data cleanup project for an Internet of Things (IoT) dataset relating to human activity recognition from smartphone data. The data comes from smartlab.ws via the UCI Machine Learning Repository, and is described [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones). The raw datasets and packaged files should be stored in the `./data/UCI HAR Dataset/` directory and can also be downloaded as a zip file [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). These are **not** included in this repository.

See "Instructions from course" section of this README for project details, and `./UCI HAR Dataset/README.txt` for details on the raw data.

This repository also contains an added version of the cleanup, `run_analysis_v2.R`, which goes beyond the project requirements. See `Files` below.

Note: The cleanup is done to specifications which require "tidy" data. The standard definition of this implies that variable names should not contain abbreviations. This is implemented here, but is a practice I personally disagree with--this can lead to very long variable names, which can cause more readability problems than they solve.


# Files

The repo's root directory contains:

* `Cleaning_IoT_Data.Rproj`: RStudio project file for aggregating everything in the IDE
* `codebook.md`: A file describing the data and cleanup procedure of `run_analysis.R` in more detail
* `README.md`: This file, giving a broad overview
* `run_analysis.R`: The cleanup script
* `run_analysis_v2.R`: An extra cleanup script which goes beyond the scope of the project
* `tidy_summary_UCI_HAR_Dataset.csv`: The second tidy dataset required; summarizes the first
* `tidy_UCI_HAR_Dataset.csv`: The first tidy dataset required

# Running instructions

After cloning the repo, create a new folder called `data` in the repo directory. Unzip raw data there, and run `run_analysis.R`.

# Data Changes, Notes

Much of the description herein overlaps with the material in `codebook.md`, which is more specific.

## run_analysis.R

As per the project specification in the section below, the following changes were made to the data in `run_analysis.R`:

* Testing a training sets merged into one
* Only mean and standard deviation columns retained
* The outcome variable was recoded in accordance with `activity_labels.txt`, included with the raw data. The variable was named `activity`
* The subject ID variable was named `subjectId`
* Features beside the meand and standard deviation ones were dropped. These were identified by feature names containing `mean(` and `std(`
* Features were labeled in accordance with `features.txt`, included with the raw data. Features were then renamed with the following tidy data characteristics:
    * Punctuation and spacing stripped, replaced with `lowerCamelCase`
	* Abbreviated variables renamed contextually (see table below)
* For convenience, the response value `activity` column was placed first, followed by the identifier `subjectId`, and then by the mean and standard deviation features
* `BodyBody` variables which have no description in the raw data documentation are retained and follow the same naming conventions as the rest

Abreviation | Replacement     
------------|-----------------
t           | timeDomain      
f           | frequencyDomain 
Acc         | Acceleration    
Gyro        | Velocity        
Mag         | Magnitude       

The output of this script is `tidy_UCI_HAR_Dataset.txt`.

Additionally, a second summarizing dataset is produced, `tidy_summary_UCI_HAR_Dataset.txt`. This gives the mean of each variable, grouped by subject and activity. The naming convention simply adds `mean` in front of the variable names and maintains lowerCamelCase.

## run_analysis_v2.R

Additional changes beyond the scope of the project are made in `run_analysis_v2.R`. This script performs the operations of `run_analysis.R`, but additionally retains the 128 time values per feature which were used to calculate the mean and standard deviation variables. The variable names are based on the file names with time components labeled in `Time000` format at the end of each variable name. The cleanup of these is done in the same convention as the feature names, described above. As this is beyond the scope fo the cleaning project, details of thsi dataset are not included in the codebook.

The output of this script is `./data/tidy_UCI_HAR_Dataset_v2.csv`. For space saving reasons, the `data` sub-directory and this file are nto included in the repo.

This also produces a summarizing dataset, `./data/tidy_summary_UCI_HAR_Dataset_v2.csv`, as with the other script. The naming convention is the same.


# Instructions from [course](https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project)

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.

## Review criteria 

The submitted data set is tidy.

The Github repo contains the required scripts.

GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.

The README that explains the analysis files is clear and understandable.

The work submitted for this project is the work of the student who submitted it.

## Getting and Cleaning Data Course Project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit:  
1. A tidy data set as described below
2. A link to a Github repository with your script for performing the analysis
3. A code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md
4. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected

One of the most exciting areas in all of data science right now is wearable computing - see for example [this article](http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/). Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following:

1. Merges the training and the test sets to create one data set
2. Extracts only the measurements on the mean and standard deviation for each measurement
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

# Raw data license

> License:
> ========
> Use of this dataset in publications must be acknowledged by referencing the following publication [1] 
> 
> [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
> 
> This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.
> 
> Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.