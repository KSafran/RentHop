# Load and Process Data

library(jsonlite)
library(dplyr)

hop <- fromJSON('data/train.json')

# Convert to a data.frame. Photos and features are both too long.
photos <- hop$photos
features <- hop$features

hop$features <- NULL
hop$photos <- NULL

hop <- lapply(hop, unlist) %>% as.data.frame()
hop$id <- rownames(hop)

# Add Common Features
library(tm)
counts <- TermDocumentMatrix(Corpus(VectorSource(unlist(features))))
common.features <- findFreqTerms(counts, 50)

for(feat in common.features){
  hop[[feat]] <- grepl(tolower(feat), tolower(features))
}

hop$n.photos <- unname(sapply(photos, length))

saveRDS(common.features, 'data/feature_names.rds')
saveRDS(hop, 'data/hop_df.rds')
