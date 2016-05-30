#Purpose
This CodeBook will describe the Code contained in `run_analysis.R`, the Variables involved, the Data, and any Transformations or work performed to clean up the source data.

#Dataset Background
(sourced from the dataset's README.txt file)
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

#Running the code
Simply source the `run_analysis.R` file and run the following:

1. `Download_project_data()`

2. `Read_Data()`

3. `Create_TidyData()`

4. `Create_TidyDataMeans()`

#Setup Functions and Source Data
The first two functions are administrative in nature and germane to the project: 

`Download_project_data()` will download the project files and unpack them, and 

`Read_Data()` and load the following files into memory (description from the "README.txt" included with the sample data set)

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'test/subject_test.txt': Same as above for test set 

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

###Code snippet
```r
Download_project_data <- function() {
  # 0. Download and setup data
  
    #setup, download data, and extract project data
  if(!file.exists("./data")){dir.create("./data")} #ensure /data exists
  fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  fileLocal<-"./data/UCI HAR Dataset.zip"
  download.file(fileUrl,destfile=fileLocal) #download to /data dir
  unzip(fileLocal,exdir="./data") #unpack to /data dir

}

Read_Data <- function() {
  #0. Set Directories and read-in data
  
  #set dirs
  path_root<-file.path("./data","UCI HAR Dataset")
  path_test<-file.path("./data","UCI HAR Dataset","test")
  path_train<-file.path("./data","UCI HAR Dataset","train")
  
  #read in test and train data
  TestFeatures<<-read.table(file.path(path_test, "X_test.txt" ),header=FALSE)
  TestActivity<<-read.table(file.path(path_test, "Y_test.txt" ),header=FALSE)
  TestSubject<<-read.table(file.path(path_test, "subject_test.txt" ),header=FALSE)
  
  TrainFeatures<<-read.table(file.path(path_train, "X_train.txt" ),header=FALSE)
  TrainActivity<<-read.table(file.path(path_train, "Y_train.txt" ),header=FALSE)
  TrainSubject<<-read.table(file.path(path_train, "subject_train.txt" ),header=FALSE)
  
  #read in names data
  namesActivity<<-read.table(file.path(path_root,"activity_labels.txt"),header=FALSE)
  namesFeatures<<-read.table(file.path(path_root,"features.txt"),header=FALSE)
}
```

## Section 1. Merge the training and the test sets
(note: Section 1-4 are all contained in `Create_TidyData()`)
- First the Test and Training data sets are combined
- Next these are merged into a single data frame

```r
Create_TidyData <- function() {
  # 1. Merge the training and the test sets to create one data set.
  
  #merge test/train data to individual dfs
  Features<-rbind(TestFeatures,TrainFeatures)
  Activity<-rbind(TestActivity,TrainActivity)
  Subject<-rbind(TestSubject,TrainSubject)
  
  #merge Activity and Subject, and name columns
  DescriptiveData<-cbind(Activity,Subject)
  names(DescriptiveData)<-c("activity","subject")
  
  #merge Features data for complete merge
  names(Features)<-namesFeatures$V2
  FullData<-cbind(DescriptiveData,Features)
  
```
## Section 2. Extract Specific measurements
- Only the Mean and Standard Deviation variables are to be extracted into the Tidy Dataset
- First all variables with mean() and std() included in the name are extracted to a data frame
- Next the Activity number and subject data are merged with these measurements

```r
  # 2. Extract only the measurements on the mean and standard deviation for each measurement.
  
  #find names for extract measures and create TidyData
  ExtractMeasures<-grep("mean\\()|std\\()",namesFeatures$V2,value=TRUE)
  TidyData<-FullData[,ExtractMeasures]
  
  #add subject and activity to TidyData
  TidyData<-cbind(DescriptiveData,TidyData)
```
## Section 3. Add descriptive activity names
- Activity labels describe which "activities" refer to which activity name such as Walking, Lying, etc.
- First common column names are given to the activity_label data (loaded to the namesActivity datafram)
- Next the Activity Names are matched to the TidyData dataframe  
  
```r
  # 3. Use descriptive activity names to name the activities in the data set
  
  #asign in activity names
  names(namesActivity)<-c("activity","activityname")
  
  #merge TidyData with namesActivity
  TidyData<-merge(namesActivity,TidyData,by="activity")
```

## Section 4. Appropriately label the tidy data
- Many of the data labels/names are codified and unintuitive, also they violate some of the tidy data rules
- One rule of having lowercase text only will not be followed to ensure the variables are ledgible
- First all abbreviated text (such as t, f, Acc, etc.) is rewritten to the long form name
- Second all special characters are stripped (such as parentheses, and hyphens)(note, mean and std are handled simultaneously)
- The result is the final TidyData, which is returned to memory as a dataframe and written to disk as "TidyData.txt"
  
```r
  # 4. Appropriately label the data set with descriptive variable names.
  
  #reference the "features_info.txt" file included in the sample data set
  names(TidyData)<-gsub("^t","time",names(TidyData)) #prefix 't' denotes time
  names(TidyData)<-gsub("^f","frequency",names(TidyData)) #prefix 'f' indicates frequency domain signals
  names(TidyData)<-gsub("Acc","Accelerometer",names(TidyData)) #features come from the the accelerometer and gyroscope (Acc and Gyro respectively)
  names(TidyData)<-gsub("Gyro","Gyroscope",names(TidyData))
  names(TidyData)<-gsub("Mag","Magnitude",names(TidyData)) #magnitude was calculated in "Mag" suffix variables
  names(TidyData)<-gsub("BodyBody","Body",names(TidyData)) #Body is duplicated in some variable names
  names(TidyData)<-gsub("mean\\()","Mean",names(TidyData)) #mean() = Mean value
  names(TidyData)<-gsub("std\\()","StandardDeviation",names(TidyData)) #std() = Standard deviation
  names(TidyData)<-gsub("-","",names(TidyData)) #Tidy data should have special characters removed
  
  write.table(TidyData, file="./data/TidyData.txt")
  TidyData<<-TidyData
}
```
## Section 5. Appropriately label the tidy data
- The second independent tidy data of averages for each activity and each subject by each variable
- Both reshape2 and the plyr package are used in this function
- First the TidyData is split out into separate dataframes by the activity and subject
- Second means are calculated for each feature
- Third the resulting list is coersed to a dataframe and back to columns of data
- The result is the final TidyDataMeans, which is returned to memory as a dataframe and written to disk as "TidyDataMeans.txt"

```r
Create_TidyDataMeans<-function(){
  # 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
  
  library(reshape2)
  library(plyr)
  
  #calculate means using lapply
  s<-split(TidyData,TidyData[,2:3]) #split out activity and subjects
  TidyDataMeans<-lapply(s,function(x) colMeans(x[, names(TidyData[,4:69])])) #calculate mean of each variable
  
  #convert the data from a list to column data
  TidyDataMeans<-as.data.frame(TidyDataMeans) #coerse to dataframe
  feature<-row.names(TidyDataMeans)
  TidyDataMeans<-cbind(feature,TidyDataMeans) #include row names
  TidyDataMeans<-melt(TidyDataMeans) #revert means to three columns of data
  
  #break "variable" column back into activityname and subject  
  TidyDataMeans$variable<-sub("\\."," ",TidyDataMeans$variable)
  df <- ldply(strsplit(TidyDataMeans$variable, " "))
  names(df) <- c("activityname", "subject")
  TidyDataMeans<-cbind(df,TidyDataMeans)
  TidyDataMeans$variable<-NULL
  
  write.table(TidyDataMeans, file="./data/TidyDataMeans.txt")
  TidyDataMeans<<-TidyDataMeans
}
```



