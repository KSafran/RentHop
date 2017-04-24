# Loading Functions
library(stringr)
library(tm)
library(xgboost)
library(data.table)
library(dplyr)
library(lubridate)
library(jsonlite)
library(ggplot2)
library(reshape2)

#' Load Renthop Datasets
#' 
#' @param file.location character location of json or RDS file, without extension
#' @param features.location character location of features RDS file
#' @param create.new.features logical indicating whether or not to create features from a
#' term document matrix or to use features saved in the features.location
#' 
#' @value a data.frame of renthop data

load_renthop <- function(file.location, features.location, create.new.features = F){
  json.file <- paste0(file.location, '.json')
  rds.file <- paste0(file.location, '.RDS')
  
  if(file.exists(rds.file)){
    return(readRDS(rds.file)) # If we have an RDS saved, just read that
  }
  
  hop <- fromJSON('data/train.json')
  
  # Photos and features are lists, won't fit neatly in data.frame. We will save them separately
  photos <- hop$photos
  features <- hop$features
  hop$features <- NULL
  hop$photos <- NULL
  
  hop <- lapply(hop, unlist) %>% as.data.frame() 
  
  # We want to grab the most common features from the training set. For testing we want
  # to use the same features as in training
  if(create.new.features){
    counts <- TermDocumentMatrix(Corpus(VectorSource(unlist(features))))
    common.features <- findFreqTerms(counts, 50)
    saveRDS(common.features, features.location)
  } else {
    common.features <- readRDS(features.vector)
  }
   
  for(feat in common.features){
    hop[[feat]] <- grepl(tolower(feat), tolower(features))
  }
  
  # Names should be standardized
  colnames(hop) <- rename_features(colnames(hop))
  
  # Add some additional features
  hop <- hop %>% 
    mutate(description.length = nchar(as.character(hop$description)),
           price.per.bedrooms = ifelse(is.infinite(price/bedrooms), 0, price/bedrooms),
           price.per.bath = ifelse(is.infinite(price/bathrooms), 0, price/bathrooms),
           n.photos = unname(sapply(photos, length)))
  
  # xgboost requires multiclass response to be labeled as integers, starting with 0
  interest_num <- data.table(interest_level = c('low','medium','high'), class = c(0,1,2))
  hop <- merge(hop, interest_num, by = 'interest_level', all.x = T, sort = F)
  
  # The TDM takes a while, so we should save for easier future loading
  saveRDS(hop, 'data/hop_df.rds')
}

# Fix Feature Names
rename_features <- function(x){
  x <- gsub("-|/", '_', x)
  x <- gsub('\\(|\\)|\\.$', '', x)
  x <- gsub('2', 'two_', x)
  x
}
