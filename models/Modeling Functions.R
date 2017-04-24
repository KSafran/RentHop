### Modeling Functions

logit <- function(x){
  1/(1 + exp(-x))
}

reshape_predictions <- function(predictions, nclass){
  matrix(predictions, ncol = nclass, byrow = TRUE)
}

reshape_actuals <- function(actuals){
  cbind(actuals == 0, actuals == 1, actuals == 2)
}

competition_loss <- function(predictions, actuals){
  scaled.preds <- rescale_probabilities(predictions)
  shaped.actuals <- reshape_actuals(actuals)
  -sum(shaped.actuals * scaled.preds)/nrow(shaped.actuals)
}

rescale_probabilities <- function(x){
  scaled.x <- x/rowSums(x)  
  pmax(pmin(scaled.x, (1 - 1e-15)), 1e-15) %>% 
    log()
}


