# Getting and Cleaning Data Course Project
Daniel B. (ddashizzle)

##Introduction
This repository contains code to perform analysis on the Human Activity Recognition Using Smartphones Data Set.
Also contained here is a codebook "CodeBook.md" which will describe the approach and how to run the script "run_analysis.R".

The original dataset may be found at [Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

##Running the script
The script is composed of 4 functions that perform the fundamental tasks:

`Download_project_data()` - downloads the zip file and unpacks to a ./data directory (run only if needed)

`Read_Data()` - load data from source files to memory

`Create_TidyData()` - turn raw data into TidyData

`Create_TidyDataMeans()` - create means data from TidyData

The `Create_TidyDataMeans()` function requires the reshape2, and plyr packages to be installed.
Both `Create_~` functions will load the resulting data frames into memory and write .txt files using write.table.

##Project Requirements
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

##Supplemental Information
Supplemental information can be found in the `CodeBook.md` file in this repository, or on the Coursera site relating to this final project.


