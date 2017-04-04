#set up workspace
#load in libraries
library(xgboost)
library(data.table)
library(dplyr)
library(lubridate)
library(jsonlite)
library(ggplot2)
library(reshape2)
source('loading_functions.R')
#read in data
hop <- readRDS('data/hop_df.rds')
colnames(hop) <- rename_features(colnames(hop))

# Let's extract some features 
description.regex <- c(website = 'website_redacted',
                       description.view = 'view')
hop <- hop %>% 
  mutate(description.length = nchar(as.character(hop$description)),
         price.per.bedrooms = ifelse(is.infinite(price/bedrooms), 0, price/bedrooms),
         price.pre.bath = ifelse(is.infinite(price/bathrooms), 0, price/bathrooms))
         
#numeric response variable for XGBoost
#Low = 1; Medium = 2; High = 3;
interest_num <- data.table(interest_level = c('low','medium','high'), class = c(0,1,2))
hop <- merge(hop, interest_num, by = 'interest_level', all.x = T, sort = F)
