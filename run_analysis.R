###################################################
#### load necessary libraries needed for code  ####
###################################################

library("data.table")
library("stringr")

###############################################################
#### read the data from the files in the working directory ####
###############################################################

obs_train_table <- fread("X_train.txt")
obs_test_table <- fread("X_test.txt")

labels_train_table <- fread("y_train.txt")
labels_test_table <- fread("y_test.txt")

subject_train_table <- fread("subject_train.txt")
subject_test_table <- fread("subject_test.txt")

###################################################
#### read helper data from files on the drive  ####
###################################################


#load activity labels and feature names (column map) helper tables.
actLabels <- fread("activity_labels.txt")

#Label activity helper table columns and convert text to character for string use
actLabels <- rename(actLabels, activity_id = V1)
actLabels <- rename(actLabels, activity = V2)
actLabels$activity <- as.character(actLabels$activity)

#load feature names (column variable map)
featureNames <- read.table("features.txt")

#####################################################
#### create filter to programmatically pull cols ####
#### to use only the ones with mean and std      ####
#####################################################

filter <- as.logical(as.integer(!is.na(as.logical(str_locate(featureNames[,2], "mean")))) * as.integer(is.na(as.logical(str_locate(featureNames[,2], "meanFreq")))) + as.integer(!is.na(as.logical(str_locate(featureNames[,2], "std")))) )
colNamesToRetain <- featureNames[filter[1:561],]


####################################################
#### combine data tables by type before merging ####
####################################################

#create single tables for observational data, activity label key and for subject ids
obs_comb <- rbind(obs_train_table, obs_test_table)
labels_comb <- rbind(labels_train_table, labels_test_table)
subject_comb <- rbind(subject_train_table, subject_test_table)

#now garbage collection to free up RAM
rm(labels_test_table, labels_train_table, obs_test_table, obs_train_table, subject_test_table, subject_train_table)

#change column labels for the obs_comb table to be more descriptive.
#column order in obs_comb matches the descriptor labels by row number in featureNames
curCounter = 0
for(curColNum in featureNames[,1]) {
    names(obs_comb)[curColNum] <- as.character(featureNames[curColNum, 2])
}

# keep only columns with mean() or std() in title.
# using data.table .SDcols and a list of col names to filter

colNamesToRetain <- as.character(as.list(as.character(colNamesToRetain[,2])))
full_comb <- obs_comb[, .SD, .SDcols = colNamesToRetain]


#### now combine all the data into a single table ####

full_comb <- cbind(labels_comb, full_comb)
full_comb <- cbind(subject_comb, full_comb)



#### clean up column names
names(full_comb)[2] <- "activity_id"
names(full_comb)[1] <- "subject_id"

setnames(full_comb, names(full_comb), as.character(str_replace(names(full_comb),"\\(", "")))
setnames(full_comb, names(full_comb), as.character(str_replace(names(full_comb),"\\)", "")))
setnames(full_comb, names(full_comb), as.character(str_replace_all(names(full_comb),"\\-", "")))

#now garbage collection
rm(labels_comb,obs_comb, subject_comb)


#add the activity text to data set to flatten tables
full_comb <- join(full_comb, actLabels)

#relabel column name
names(full_comb)[ncol(full_comb)] <- "activity_name"

#just because I like to move the descriptors to the left side of the column set
setcolorder(full_comb, c(1,2,69,3:68))


###################################################
####  Completes steps 1-4 in the assignment  ######
###################################################


#######################################################################################
####  Now to do step 5, create a new independent tidy data set with average (mean) ####
####  of each variable for each activity and subject                               ####
#######################################################################################

avg_output <- full_comb[, lapply(.SD, mean), by=.(subject_id, activity_id), .SDcols=names(full_comb)[4:69]]

#join with activity lables helper table to flatten tables an add human readable activity names to the data table.
setkey(avg_output, activity_id)
setkey(actLabels, activity_id)
avg_output <- avg_output[actLabels]

#just because I like to move the descriptors to the left side of the column set
setcolorder(avg_output, c(1,2,69,3:68))

# final garbage collection
rm(actLabels, featureNames)

########################################################################################
####  Leaves two data tables in memory                                              ####
####  1) full_comb  - observational data with means and standard deviations,        ####
####                  activity names and descriptive col names                      ####
####  2) avg_output - aggregated mean for each variable by activity and subject     ####
########################################################################################


###############################################
#### write the two tidy data sets to files ####
###############################################

write.table(full_comb, "tidy.txt", row.name=FALSE)
write.table(avg_output, "tidy_avg.txt", row.name=FALSE)

