




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
  
  
  # 2. Extract only the measurements on the mean and standard deviation for each measurement.
  
  #find names for extract measures and create TidyData
  ExtractMeasures<-grep("mean\\()|std\\()",namesFeatures$V2,value=TRUE)
  TidyData<-FullData[,ExtractMeasures]
  
  #add subject and activity to TidyData
  TidyData<-cbind(DescriptiveData,TidyData)
  
  # 3. Use descriptive activity names to name the activities in the data set
  
  #asign in activity names
  names(namesActivity)<-c("activity","activityname")
  
  #merge TidyData with namesActivity
  TidyData<-merge(namesActivity,TidyData,by="activity")
  
  
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
  
  TidyData<<-TidyData
}


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
  
  TidyDataMeans<<-TidyDataMeans
}


