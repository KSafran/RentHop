# Score Competition Data

competition.data.location <- 'C:/Users/Kyle/Desktop/renthop data/test.json'
common.features <- readRDS('data/feature_names.rds')
gbm <- readRDS('data/gbm.rds')
source('renthop data loading.R')
library(xgboost)

competition.data <- read_renthop_data(file.location = competition.data.location,
                                      features.to.extract = common.features)

no.response.formula <- gbm$formula
no.response.formula[2] <- NULL
competition.matrix <- model.matrix(object = gbm$formula, data = competition.data)
competition.xgb <- xgb.DMatrix(competition.matrix)

fitted.values <- predict(gbm$model, newdata = competition.xgb,
                         ntreelimit = gbm$model$best_ntreelimit) %>% 
  reshape_predictions(3)

submission <- cbind(competition.data$listing_id, fitted.values[, c(3,2,1)])
colnames(submission) <- c('listing_id', 'high', 'medium', 'low')
write.csv(submission, 'leaderboard_submission.csv', row.names = FALSE)
