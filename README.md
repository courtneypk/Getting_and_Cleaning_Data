# Getting_and_Cleaning_Data
Getting and Cleaning Data Project

The overall plan for this analysis is to break it down into "bite-size" pieces. This makes it easier to follow the changes made at the different steps in the process.

The initial steps are to read in the data from the various files required. I found that the readr package was invaluable in reducing the time to read in such large files as "X_test.txt" and "X_train.txt". I also made sure that the data from the Test and Train data were "stacked" using either rbind or cbind in order to preserve the order of the data.

Towards the end I took many steps, perhaps too many, to get the data into tidy form. But I didn't want to take too large a leap and lose data integrity.