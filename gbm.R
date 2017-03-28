### First GBM

# Loading the Training Data
# Right now we can just source this utils script, but we should 
# wrap this in a function something like 
# source(utils.R)
# load_libraries()
# hop <- load_training_data()
source('utils.R')
source('Modeling Functions.R')

# Set up GBM
train.indicator <- runif(nrow(hop)) < 0.7

# Set Predictors
predictors <- hop %>% 
  select(bathrooms, bedrooms, latitude, longitude, price,
         two_br:n.photos) %>% colnames()

model.formula <- as.formula(paste0('class ~ ',
                                   paste(predictors, collapse = ' + '),
                                   ' - 1')) # removes intercept

train.matrix <- model.matrix(model.formula, data = hop[train.indicator,])
train.xgbd.matrix <- xgb.DMatrix(train.matrix, label = hop$class[train.indicator])
test.matrix <- model.matrix(model.formula, data = hop[!train.indicator,])
test.xgbd.matrix <- xgb.DMatrix(test.matrix, label = hop$class[!train.indicator])
watchlist <- list(train = train.xgbd.matrix, eval = test.xgbd.matrix)

gbm.parameters <- list(eta = 0.1,
                       max.depth = 5,
                       min_child_weight = 10,
                       subsample = 0.8,
                       colsample_bytree = 0.8,
                       lambda = 1,
                       objective = 'multi:softprob',
                       num_class = 3)

set.seed(10)
gbm.model <- xgb.train(params = gbm.parameters,
                       data = train.xgbd.matrix,
                       watchlist = watchlist,
                       nrounds = 1000,
                       print_every_n = 10,
                       early_stopping_rounds = 25)

test.predictions <- predict(gbm.model, newdata = test.xgbd.matrix,
                            ntreelimit = 226) %>% 
  reshape_predictions(3)

competition_loss(predictions = test.predictions, 
                 actuals = hop$class[!train.indicator])

model.specs <- structure(list(model = gbm.model,
                              formula = model.formula ),
                         class = 'xgboost.model')
saveRDS(model.specs, file = 'data/gbm.rds')
