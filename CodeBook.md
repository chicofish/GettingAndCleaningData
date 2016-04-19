# Getting and Cleaning Data Course Project
## Code Book
#### Fred Smith

The data in provided are the result of culling and aggregation from "Human Activity Recognition Using Smartphones Datasets" (HAR) as provided by Snartlab from Università degli Studi di Genova. (see ReadMe.md and ReadMe_HAR.txt for more information.)

The run_analysis.R file contains the script for the Data Transformation operations from the original data provided by HAR to produce the smaller set of averaged aggregate data.

run_analysis.R performs the following steps:

1. loads the necessary R packages: data.table and stringR
2. reads the data for the test and training data, labels and subject ids from the working directory.
3. reads the helper data from the features.txt and activity_labels.txt files from the working directory, which will be used to make descriptive column names and activity names for later processing
4. Combines the different data tables into a single data table, changes the column labels to be more descriptive, drops all columns that are not mean (mean) or standard deviation (std) measurements
5. Reorders the columns so that subject_id, activity_id and activity_name are on the left for easier scanning.
6. Creates a new data table that creates an average (mean) for each activity by each subject to further reduce and summarize the data.
7. Finally, the script writes the two tidy data sets to the local drive: tidy.txt and tidy_avg.txt

1. Make my changes 
1. Fix bug 
2. Improve formatting 
* Make the headings bigger 
2. Push my commits to GitHub 
3. Open a pull request 
* Describe my changes 
* Mention all the members of my team 
* Ask for feedback





