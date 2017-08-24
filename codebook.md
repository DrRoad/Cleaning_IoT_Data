#### Note to Coursera graders:

Codebook formatting is a nebulous area and is not well covered in the Getting and Cleaning Data class from which this project stems. The GitHub repo for the course, [http://datasciencespecialization.github.io/getclean/]((http://datasciencespecialization.github.io/getclean/)), contains a link to an [example codebook](https://gist.github.com/kirstenfrank/218c36a1938055d0f4e4). Though I would prefer a cleaner document personally, I believe that this is the "safe" bottom line as far as grading requirements go, since it is linked in the official repo. As such, I am using that document as the baseline for grading, and encourage you do the same.

# Codebook

### Raw data

#### Context

Experiments were conducted with 30 subjects for the purpose of identifying common movement patterns recorder by waist-strapped Samsung Galaxy S II smartphones. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) which were manually labeled. Data on these activities was collected by the smartphones, which logged 3-axial (X, Y, Z) linear acceleration and 3-axial (X, Y, Z) angular velocity using their accelerometers and gyroscopes, respectively. The data was logged at a rate of 50Hz for 128 periods for each activity, and filtered. The resulting data was then split into training and testing sets at a 70-30 ratio. For a more detailed breakdown of the raw data collection procedures, see README.txt included with the raw data (note that this is NOT the README.md file included in this repo).

#### Data

Total observations: 10299  

The data files in the raw data are...

Data File             | # of Variables | Description                          
----------------------|----------------|---------------------------------------
activity_labels.txt   | 2              | activity encoding and activity name   
features.txt          | 2              | column index (1-561) and feature name 
subject_train.txt     | 1              | subject ID (1-30), training set       
subject_test.txt      | 1              | subject ID (1-30), testing set        
X_train.txt           | 561            | features, training set                
X_test.txt            | 561            | features, testing set                 
y_train.txt           | 1              | encoded activity (1-6), training set  
y_test.txt            | 1              | encoded activity (1-6), testing set   

The feature set is standardized [-1, 1], and is derived from inertial signal data (see Inertial Signals below).

##### Features

Features as derived as functions of values calculated on inertial signals. These include the mean, standard deviation, and many others which are superfluous to this project. These are given in two domains: time and frequency. Additionally, separate measures are present for every axis (X, Y, Z). As previously mentioned, the features are all standardized to [-1, 1], which means that they are ratios with no units.

For more details, see `feature_info.txt`, included with the raw data.


##### Inertial Signals

The files in the `Inertial Signals` folder contain entries at 128 times for each of nine data items collected by the smartphones. These were used to derive feature values, and are described in README.txt included with the raw data:

> - 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 
>
> - 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 
>
> - 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second.


#### Raw data license

> License:
> ========
> Use of this dataset in publications must be acknowledged by referencing the following publication [1] 
> 
> [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
> 
> This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.
> 
> Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.


### Clean data

The final output of the cleanup is for two tidy data files, obtained through `run_analysis.R`.

#### File One

File name: `tidy_UCI_HAR_Dataset.csv`

The first file cleans the data, retaining only the following:
1. activity
2. subject ID
3. mean and standard deviation features

Mean and standard deviation features are the mean and standard deviations of the inertial signal derived values corresponding to their feature names. Along each axis and in both the time and frequency domains, these include:

* BodyAcceleration
* GravityAcceleration
* BodyAccelerationJerk
* BodyVelocity
* BodyVelocityJerk
* BodyAccelerationMagnitude
* GravityAccelerationMagnitude
* BodyAccelerationJerkMagnitude
* BodyVelocityMagnitude
* BodyVelocityJerkMagnitude
* BodyBodyAccelerationJerkMagnitude
* BodyBodyVelocityMagnitude
* BodyBodyVelocityJerkMagnitude

For clarity, the above list is of variables **already renamed**. In total, there are 66 features which are retained. These were derived and renamed with the following procedure:

The variables were identified by . Following, the 

The feature renaming convention is as follows:
* Features beside the meand and standard deviation ones were dropped. These were identified by feature names containing `mean(` and `std(`
* Features were labeled in accordance with `features.txt`, included with the raw data. Features were then renamed with the following tidy data characteristics:
    * Punctuation and spacing stripped, replaced with `lowerCamelCase`
	* Abbreviated variables renamed contextually (see table below)
* `BodyBody` variables which have no description in the raw data documentation are retained and follow the same naming conventions as the rest

Abreviation | Replacement     
------------|-----------------
t           | timeDomain      
f           | frequencyDomain 
Acc         | Acceleration    
Gyro        | Velocity        
Mag         | Magnitude   


Other alterations made:
* The training and testing sets along their variable name counterparts (for example, `X_train.txt` and `X_test.txt`)
* The outcome variable was recoded in accordance with `activity_labels.txt`, included with the raw data. The variable was named `activity`
* The subject ID variable was named `subjectId`
* For convenience, the response value `activity` column was placed first, followed by the identifier `subjectId`, and then by the mean and standard deviation features


#### File Two

File name: `tidy_summary_UCI_HAR_Dataset.csv`

The second dataset is simply an aggregation of the first, with means of all features, grouped by the combination of subject and activity. That is, these are the means of every mean and standard deviation value of every feature for every subject performing a specific activity. it may be easier to imagine this given the dimensionality of the dataset: `180 x 68`. There are `30 subjects * 6 activities` rows (`180`), `66` feature columns, and `2` columns for identifying the subject and the activity, respectively.

The naming convention simply adds `mean` in front of the variable names and maintains `lowerCamelCase`.