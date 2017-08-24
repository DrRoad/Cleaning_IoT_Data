rm(list = ls())

# load packages -----------------------------------------------------------

pacman::p_load(data.table)


# get and organize file paths and names -----------------------------------

# train and test folder directory paths
wd <- getwd()
testDir <- paste0(wd, "/data/UCI HAR Dataset/test")
trainDir <- paste0(wd, "/data/UCI HAR Dataset/train")
# train and test folder files & paths
testFiles <- list.files(path = testDir, recursive = F)[-1]
trainFiles <- list.files(path = trainDir, recursive = F)[-1]
testPaths <- paste0(testDir, "/", testFiles)
trainPaths <- paste0(trainDir, "/", trainFiles)

# match training and testing paths
paths <- cbind(testPaths, trainPaths)


# bind training and testing data ------------------------------------------

bind <- function(paths){
  # A generalized binding function for training and testing data. Takes as
  #   input a vector of the paths of training and testing files of same format
  #   data. Reads files as data.tables and combines them with rbind().
  
  # check package dependency
  if(!require(data.table)) stop("Failed to load data.table package")
  
  one <- fread(paths[1])
  two <- fread(paths[2])
  
  rbind(one, two)
}
# bind every testing-training pair
bound <- apply(paths, 1, bind)
str(bound, max.level = 1)

# make names for bound data by droping "_test.txt"
boundNames <- sub("_test.txt", "", testFiles)


# limit & label variables -------------------------------------------------

# define function for tidy-ing strings (lower camel case)
toLowerCamel <- function(s){
  # Removes punctuation and space characters from string s and returns in lower
  # camel case. Be careful not to use this blindly across variable names, as
  # sometimes these can include ranges. This function would convert "Band12,31"
  # to "Band1231" which may cause the variable name to lose meaning.
  s <- strsplit(s, "")[[1]]
  punctInd <- grep("[[:punct:][:space:]]", s)
  s[punctInd + 1] <- toupper(s[punctInd + 1])
  if (is.na(s[length(s)])){
    s <- s[-length(s)]
  }
  s[1] <- tolower(s[1])
  paste0(s[-punctInd], collapse = "")
}

# limit features to mean() and std() only
#   get feature names
features <- fread(paste0(wd, "/data/UCI HAR Dataset/features.txt"))
#   get relevant IDs
relevantFeatureIDs <- grep("mean\\(|std\\(", features$V2)
#   tidy up feature names
features[[2]] <- sub("^t", "timeDomain", features[[2]])
features[[2]] <- sub("^f", "frequencyDomain", features[[2]])
features[[2]] <- sub("Acc", "Acceleration", features[[2]])
features[[2]] <- sub("Gyro", "Velocity", features[[2]])
features[[2]] <- sub("Mag", "Magnitude", features[[2]])
features[[2]] <- sapply(features[[2]], toLowerCamel)
#   drop all but relevant features
colnames(bound[[2]]) <- features[[2]]
bound[[2]] <- bound[[2]][, relevantFeatureIDs, with = F]

# label y variable
#   get activity names
activities <- fread(paste0(wd, "/data/UCI HAR Dataset/activity_labels.txt"))
encoding <- activities[, 2][[1]]
#   convert to factor and relevel
bound[[3]][[1]] <- factor(bound[[3]][[1]])
levels(bound[[3]][[1]]) <- encoding
#   cast back to a data.table for consistency and name
bound[[3]] <- data.table(activity = bound[[3]][[1]])

# label subcet id variable
colnames(bound[[1]]) <- "subjectId"


# combine into single table -----------------------------------------------

dt <- cbind(bound[[3]], bound[[1]], bound[[2]])
# write the csv (write.table for submission requirements)
# fwrite(dt, file = "tidy_UCI_HAR_Dataset.csv")
write.table(dt, file = "tidy_UCI_HAR_Dataset.txt", row.names = F)

# mean by subject and activity --------------------------------------------

# summarize
dt2 <- dt[, lapply(dt[, -c(1, 2)], mean), by = .(subjectId, activity)]
# change variable names
varNames <- colnames(dt2)[-(1:2)]
renameMeanUpper <- function(s){
  first <- toupper(substr(s, 1, 1))
  remaining <- substr(s, 2, nchar(s))
  paste0("mean", first, remaining)
}
colnames(dt2) <- c(colnames(dt2)[1:2], sapply(varNames, renameMeanUpper))
# write the csv (write.table for submission requirements)
# fwrite(dt2, file = "tidy_summary_UCI_HAR_Dataset.csv")
write.table(dt2, file = "tidy_summary_UCI_HAR_Dataset.txt", row.names = F)