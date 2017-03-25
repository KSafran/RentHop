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
#rename problematic variables
# names(hop)[15] <- 'two_bedroom'
# names(hop)[16] <- 'air_conditioning'
# names(hop)[24] <- 'apt'
# names(hop)[38] <- 'closets'
# names(hop)[59] <- 'full_time'
# names(hop)[63] <- 'garden_patio'
# names(hop)[67] <- 'gym_fitness'
# names(hop)[78] <- 'live_in'
# names(hop)[84] <- 'multi_level'
# names(hop)[87] <- 'on_site'
# names(hop)[90] <- 'parking_garage' #note that this was previously parking/garage
# names(hop)[96] <- 'pre_war'
# names(hop)[104] <- 'roof_deck' #note that this is different from 'roofdeck'
# names(hop)[127] <- 'washer_dryer'

#numeric response variable for XGBoost
#Low = 1; Medium = 2; High = 3;
interest_num <- data.table(interest_level = c('low','medium','high'), class = c(0,1,2))
hop <- merge(hop, interest_num, by = 'interest_level', all.x = T, sort = F)
