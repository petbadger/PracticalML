# Setup Code for Prediction Assignment


# Get Data
orig_dir <- getwd()
data_dir <- '/home/jared/Documents/Prediction Assignment/data'
work_dir <- '/home/jared/Documents/Prediction Assignment'
url.train <- 'https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv'
url.test <- 'https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv'

setwd(data_dir) #download data here

#check for existince of file before downloading
download.file(url.train, 'pml-training.csv', mode = 'w')
download.file(url.test, 'pml-testing.csv', mode = 'w')


#Read in data
library(readr)
data.train <- read_csv('pml-training.csv')
data.new <- read_csv('pml-testing.csv')
saveRDS(object = data.train, file = "data.train")
saveRDS(object = data.new, file = "data.new")


setwd(work_dir)