# GettingAndCleaningDataCourseProject
## End of course assignment for: https://www.coursera.org/learn/data-cleaning

### run_analysis.R

script has the following four functions which perform part of the processing followed by the function `run` which pulls it all together and should be executed from the CLI.

#### read_data_fileset
Reads the three files relating to a dataset - test or train and creates R data.frames.

#### process_data
Reads the list of features from the codebook, finds those required (mean, std) using a regular expression. Unrequired columns are then dropped and the remaining columns renamed to the features.

#### create_summary
As per requirements, calculates the mean average of the values by activity, subject and feature

#### save_file
Writes the file to disk using write.table. Defaults unchanged for quoted and sep.

#### run
Uses above four functions and a few more R functions to process the files and write to resultant table to disk