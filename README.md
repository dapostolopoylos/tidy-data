# Getting and Cleaning Data Course Project


This repo contains all the script files, documentation files and final export file of the Coursera "Getting and Cleaning Data" course project.

* The script file, containing all the code for the analysis, is run_analysis.R.

*  Before the script execution download the data set from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and unzip it in the working directory. Name the unziped data set folder "UCI_HAR_Dataset".

* Make sure that both the data set folder and the script are in the same directory, which is the current working directory.

*  Execute script using in RStudio the command "source("run_analysis.R")".

*  When script execution finishes a data frame named "res" (180 obs. of 68 variables) is created. It contains the final tidy data set that has been exported in the current working directory in a txt file named "tidy_ds_with_average_values.txt".
