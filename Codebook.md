## Overview
This is the codebook for the Kaggle Competition involving Two Sigma and RentHop. Here, we can detail 
what our various scripts do (or, at least what they're *supposed* to do). To help streamline the 
collaboration process, any key additions or deletions should be noted here. 

## Load and EDA.R
This code reads in the `train.json` data, converts it to a data frame, and creates individual fields
for common features found in the listings. After these transformations, the data frame is saved as 
`data/hop_df.rds`.

## utils.R
This code performs some simple tasks that should make our lives easier and our code a bit cleaner. 
* Loads in various packages
* Reads in data from `data/hop_df.rds`
* Defines a numeric response variable `class` 
	* 1 = low interest
	* 2 = medium interest
	* 3 = high interest
* Renames any variables that include problematic characters (such as hyphens, slashes, or parentheses)