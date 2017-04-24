### First GBM

# Config
data.location <- 'C:/users/Kyle/Desktop/renthop data'

# Setup and Load
source('/load and process/loading_functions.R')
source('Modeling Functions.R')
hop <- load_renthop(paste0(data.location, '/train'),
                    features.location = paste0(data.location, '/feature_names.rds'),
                    create.new.features = F)

# Set up GBM
set.seed(0)
train.indicator <- runif(nrow(hop)) < 0.7

# Set Predictors
predictors <- hop %>% 
  select(bathrooms, bedrooms, latitude, longitude, price,
         two_br:windows, description.length, price.per.bath, 
         price.per.bedrooms, n.photos) %>% colnames()

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
