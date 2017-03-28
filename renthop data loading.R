### Renthop Data Loading Functions

library(jsonlite)
library(dplyr)
library(stringr)


# file.location the quoted path to the unzipped json file
# features.to.extract a character vector of features to extract from the
# features field

read_renthop_data <- function(file.location, features.to.extract){
  # load JSON
  raw <- fromJSON(file.location)
  # remove the photos and features from the data, they are too long for
  # transformation into the data.frame. Save them first so we can use them
  # later
  photos <- raw$photos
  features <- raw$features
  raw$photos <- NULL
  raw$features <- NULL
  
  raw <- lapply(raw, unlist) %>% as.data.frame()
  raw$id <- rownames(raw)
  
  for(feat in features.to.extract){
    raw[[feat]] <- grepl(tolower(feat), tolower(features))
  }
  
  raw$n.photos <- unname(sapply(photos, length))
  
  colnames(raw) <- rename_features(colnames(raw))
  raw
}

rename_features <- function(x){
  x <- gsub("-|/", '_', x)
  x <- gsub('\\(|\\)|\\.$', '', x)
  x <- gsub('2', 'two_', x)
  x
}
