### Neural Net Data Prep
data.location <- 'C:/Users/Kyle/Desktop/Renthop data'

source('utils.R')

source('Modeling Functions.R')

# Set up GBM
set.seed(0)
train.indicator <- runif(nrow(hop)) < 0.7

# Set Predictors
predictors <- hop %>% 
  select(bathrooms, bedrooms, latitude, longitude, price, description.length,
         price.per.bedrooms, price.pre.bath, two_br:n.photos) %>% 
  colnames()

model.formula <- as.formula(paste0('class ~ ',
                                   paste(predictors, collapse = ' + '),
                                   ' - 1')) # removes intercept

train.matrix <- model.matrix(model.formula, data = hop[train.indicator,])

# We need to rescale to 0-1, but we should save the transformations so 
# we can use the same ones on the testing set

ranges <- apply(train.matrix, 2, function(x) diff(range(x)))
mins <- apply(train.matrix, 2, min)

# Scale
train.matrix <- sweep(train.matrix, 2L, FUN = '/', ranges)
# Center
train.matrix <- sweep(train.matrix, 2L, FUN = '-', mins/ranges)

scaling.parameters <- structure(list(ranges = ranges,
                                     mins = mins),
                                class = 'scale_par')
saveRDS(scaling.parameters, 'data/nn_scale_params.rds')

# Apply to test data

scaling.parameters <- readRDS('data/nn_scale_params.rds')

test.matrix <- model.matrix(model.formula, data = hop[!train.indicator,])
# Scale
test.matrix <- sweep(test.matrix, 2L, FUN = '/', scaling.parameters$ranges)
# Center
test.matrix <- sweep(test.matrix, 2L, FUN = '-', scaling.parameters$mins/scaling.parameters$ranges)

# Labels one-hot
train.labels <- reshape_actuals(hop$class[train.indicator])
train.labels <- apply(train.labels, 2, as.numeric)

test.labels <- reshape_actuals(hop$class[!train.indicator])
test.labels <- apply(test.labels, 2, as.numeric)

# Save for tensorflow
write.csv(train.matrix, sprintf('%s/nn_train.csv', data.location), 
          row.names = F)
write.csv(test.matrix, sprintf('%s/nn_test.csv', data.location), 
          row.names = F)

write.csv(train.labels, sprintf('%s/nn_train_labs.csv', data.location), 
          row.names = F)
write.csv(test.labels, sprintf('%s/nn_test_labs.csv', data.location), 
          row.names = F)
