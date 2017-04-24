### Download Photos

library(jsonlite)
library(dplyr)

photo.folder <- 'C:/Users/Kyle/Desktop/renthop data/train images'

hop <- fromJSON('data/train.json')
photos <- hop$photos
listing.ids <- unlist(hop$listing_id)

library(jpeg)

# Lets grab the photos and collect summary statistics
# these will includes average color values, image dimensions

photo.data <- data.frame(height = rep(0, length(photos)),
                         width = rep(0, length(photos)),
                         brightness = rep(0, length(photos)))
pics <- list()
system.time(for(i in 1:100){
  if(length(photos[[i]]) == 0) {next}
  pic.filename <- paste0(photo.folder, '/train_', i, '.jpg')
  download.file(photos[[i]][1], pic.filename, mode="wb")
  this.pic <- readJPEG(pic.filename)
  size <- dim(this.pic)
  photo.data[i, ] <- c(size[1:2], mean(this.pic))
  rm(this.pic)
}
)

