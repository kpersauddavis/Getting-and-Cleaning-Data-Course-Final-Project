
#Download Data Set
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/FinalProject.zip",method="curl")

#Unzip Download
unzip(zipfile="./data/FinalProject.zip",exdir="./data")

#Create path to file
path <- file.path("./data", "UCI HAR Dataset")

#Read in Various Elements of Dataset
Act_Train <- read.table(file.path(path, "train","Y_train.txt"),header = FALSE)
Act_Test <- read.table(file.path(path, "test","Y_test.txt"),header = FALSE)
Sub_Train <- read.table(file.path(path, "train","Subject_train.txt"),header = FALSE)
Sub_Test <- read.table(file.path(path, "test","Subject_test.txt"),header = FALSE)
Feat_Train <- read.table(file.path(path, "train","X_train.txt"),header = FALSE)
Feat_Test <- read.table(file.path(path, "test","X_test.txt"),header = FALSE)
Feat_Names <- read.table(file.path(path, "features.txt"), header=FALSE)
Act_Labels <- read.table(file.path(path, "activity_labels.txt"), header = FALSE)
#Merge Train/Test Datasets
Act_Data <- rbind(Act_Train,Act_Test)
Sub_Data <- rbind(Sub_Train,Sub_Test)
Feat_Data <- rbind(Feat_Train, Feat_Test)

#Create Labels for the Datasets
names(Sub_Data) <- c("Subject")
names(Act_Data) <- c("Activity")
names(Feat_Data) <- Feat_Names$V2

#Combine all Datasets
Comb_Data <- cbind(Sub_Data, Act_Data)
Final_Data <- cbind(Feat_Data, Comb_Data)

#Parse out only measurements on Mean and Std. Deviation
Sub_Data_Names <- Feat_Names$V2[grep("mean\\(\\)|std\\(\\)", Feat_Names$V2)]

#Subset Final Dataset
Select_Names <- c(as.character(Sub_Data_Names), "Subject", "Activity")
Final_Data <- subset(Final_Data, select = Select_Names)

#Force Activity in Final_Data to a factor variable
Final_Data$Activity <- factor(Final_Data$Activity, levels = Act_Labels[,1], labels = Act_Labels[,2])
Final_Data$Subject <- as.factor(Final_Data$Subject)

#Create Appropriate Labels
names(Final_Data)<-gsub("Gyro", "Gyroscope", names(Final_Data))
names(Final_Data)<-gsub("BodyBody", "Body", names(Final_Data))
names(Final_Data)<-gsub("^f", "frequency", names(Final_Data))
names(Final_Data)<-gsub("Acc", "Accelerometer", names(Final_Data))
names(Final_Data)<-gsub("Mag", "Magnitude", names(Final_Data))
names(Final_Data)<-gsub("^t", "time", names(Final_Data))

#Create Tidy Data Set using plyr
Tidy_Data <- aggregate(.~Subject + Activity, Final_Data, mean)
Tidy_Data <- Tidy_Data[order(Tidy_Data$Subject, Tidy_Data$Activity),]
write.table(Tidy_Data, file = "tidydata.txt", row.name = FALSE)

