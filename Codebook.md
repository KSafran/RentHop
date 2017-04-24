## Overview
This is the codebook for the Kaggle Competition involving Two Sigma and RentHop. Here, we can detail what our various scripts do (or, at least what they're *supposed* to do). To help streamline the collaboration process, any key additions or deletions should be noted here. 

## load and process/loading_function.R
In here there is a function that loads in the `train.json` data, converts it to a data frame, and creates individual fields for common features found in the listings. After these transformations, the data frame is saved as an .rds file to streamline loading.

## gbm.R
This code reads in the training data, and fits a GBM. At this point we haven't really done much cross-validation, so there is a lot of room to improve this model. The end goal here would be an automated grid search (or bayesian hyperparameter optimization).

## Modeling Functions.R
This code contains some basic functions for model fitting. It includes the loss function used for scoring competition entries.

## images/download_photos.R
This file downloads the first photo associated with each listing and extracts some basic metadata about the file. The end goal here would be to feed these photos into tensorflow in python.