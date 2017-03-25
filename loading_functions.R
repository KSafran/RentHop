# Loading Functions
library(stringr)

rename_features <- function(x){
  x <- gsub("-|/", '_', x)
  x <- gsub('\\(|\\)|\\.$', '', x)
  x <- gsub('2', 'two_', x)
  x
}
