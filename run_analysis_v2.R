

rm(list = ls())

# load packages -----------------------------------------------------------

pacman::p_load(data.table, stringr)


# get and organize file paths and names -----------------------------------

# train and test folder directory paths
wd <- getwd()
testDir <- paste0(wd, "/data/UCI HAR Dataset/test")
trainDir <- paste0(wd, "/data/UCI HAR Dataset/train")
# train and test folder file & sub-directory paths
testFiles <- list.files(path = testDir, recursive = F)
trainFiles <- list.files(path = trainDir, recursive = F)
testPaths <- paste0(testDir, "/", testFiles)
trainPaths <- paste0(trainDir, "/", trainFiles)
# intertial file directory paths
testInertPath <- testPaths[1]
trainInertPath <- trainPaths[1]
# remove sub-directory paths from top level train and test folder
#   file paths and file names
testPaths <- testPaths[-1]
trainPaths <- trainPaths[-1]
testFiles <- testFiles[-1]
trainFiles <- trainFiles[-1]
# train and test intertial file paths
testInertFiles <- list.files(testInertPath)
trainInertFiles <- list.files(trainInertPath)
testInertPaths <- paste0(testInertPath, "/", testInertFiles)
trainInertPaths <- paste0(trainInertPath, "/", trainInertFiles)

# match training and testing paths and files
paths <- list(topLevel = cbind(testPaths, trainPaths),
              inertial = cbind(testInertPaths, trainInertPaths))
files <- list(topLevel = cbind(testFiles, trainFiles),
              inertial = cbind(testInertFiles, trainInertFiles))

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
bound <- lapply(paths, function(x) apply(x, 1, bind))
str(bound, max.level = 2)

# make names for bound data (for ease of cleanup, not relevant to output)
#   pull out testing file names
boundNames <- lapply(files, function(x) x[, 1])
#   drop "_test.txt"
boundNames <- lapply(boundNames, function(x) sub("_test.txt", "", x))


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
colnames(bound$topLevel[[2]]) <- features[[2]]
bound$topLevel[[2]] <- bound$topLevel[[2]][, relevantFeatureIDs, with = F]

# label y variable
#   get activity names
activities <- fread(paste0(wd, "/data/UCI HAR Dataset/activity_labels.txt"))
encoding <- activities[, 2][[1]]
#   convert to factor and relevel
bound[[1]][[3]][[1]] <- factor(bound[[1]][[3]][[1]])
levels(bound[[1]][[3]][[1]]) <- encoding
#   cast back to a data.table for consistency and name
bound[[1]][[3]] <- data.table(activity = bound[[1]][[3]][[1]])

# label subcet id variable
colnames(bound[[1]][[1]]) <- "subjectId"

# relabel inertial variables
#   define relabeling function
renameInertial <- function(dt, fileName){
  fileName <- sub("Acc", "Acceleration", fileName)
  fileName <- sub("Gyro", "Velocity", fileName)
  times <- str_pad(1:ncol(dt), nchar(ncol(dt)), pad = 0)
  label <- paste0(fileName, "Time", 1:ncol(dt))
  colnames(dt) <- label
  dt
}
#   relabel variables in each table/file
for (table in 1:length(bound$inertial)){
  fileName <- toLowerCamel(boundNames$inertial[table])
  bound$inertial[[table]] <- renameInertial(bound$inertial[[table]], fileName)
}


# combine into single table -----------------------------------------------

dt <- cbind(bound$topLevel[[3]], bound$topLevel[[1]], bound$topLevel[[2]],
            do.call("cbind", bound$inertial))
# write the csv
fwrite(dt, file = "./data/tidy_UCI_HAR_Dataset_v2.csv")

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
# write the csv
fwrite(dt2, file = "./data/tidy_summary_UCI_HAR_Dataset_v2.csv")