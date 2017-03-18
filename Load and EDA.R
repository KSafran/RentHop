# Load and EDA

library(jsonlite)
library(dplyr)

hop <- fromJSON('data/train.json')

# Convert to a data.frame. Photos and features are both too long.
photos <- hop$photos
features <- hop$features

hop$features <- NULL
hop$photos <- NULL

hop2 <- lapply(hop, unlist) %>% as.data.frame()
hop2$id <- rownames(hop2)
# Add features as dummy variables
unique.features <- unique(unlist(features))
feature.extractor <- function(x){
  x %in% features[[i]]
}

library(tm)
counts <- TermDocumentMatrix(Corpus(VectorSource(unlist(features))))
common.features <- findFreqTerms(counts, 50)

for(feat in unique.features){
  hop2[[feat]] <- grepl(feat, features)
}
