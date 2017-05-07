# Prediction Assignment Code

### Run setup_data.R first ###

data.train <- readRDS("data/data.train")
data.new <- readRDS("data/data.new")


#About the  data
dim(data.train)
dim(data.train)[1]
dim(data.train)[2]
names(data.train)
names(data.new)

#check size of the data set, since modelling this much data might hit RAM limitations
print(object.size(data.train), units='auto')


#note that data.train contains classe and data.new does not. 
#Data.new contains problem_id, which is probably a link back to their classe for grading purposes.


#Data Cleaning and Variable Selection

#Exclude meaningless vars (which either add noise or complexity)
exclude <- c("X1", "raw_timestamp_part_1", "raw_timestamp_part_2", "cvtd_timestamp", "num_window", "new_window", "user_name")
data.train <- data.train[ , !names(data.train) %in% exclude]

#shows that all columns with NA are about 97% or more NA.  
na_count <-sapply(data.train, function(y) sum(length(which(is.na(y)))/total_obs ))
na_count

#transpose twice to remove columns with lots of NA
keep <- names(as.data.frame( t(na.omit(t(data.train))) ) )#get list of vars that are not full of NA's
data.train <- data.train[ , names(data.train) %in% keep]
print(object.size(data.train), units='auto')

#Correlation suggests variables containing the term "total" are redundant
cor(data.train[ , !names(data.train) %in% c("classe")]) 
totals_vars <- names( data.train[ , grepl( "total" , names(data.train) )] )
data.train <- data.train[ , !names(data.train) %in% totals_vars]


#Double check for any other Near Zero Variance variables. Use Caret's nearZeroVar()
nearZeroVar(data.train) #returned none

#this shows there are very few rows that contain data in EVERY column. These will be noise for analysis.
nrow(na.omit(data.train)) #shows there are very many columns with NA
total_obs <- nrow(data.train)

#make classe a factor variable
data.train$classe <- factor(data.train$classe) 

#Can also do pairs, but itss intense with this many variables
#pairs(data.train[ , 1:10])



#Model building
set.seed(123)
inTrain <- createDataPartition(y=data.train$classe, p=0.75, list=FALSE)
training <- data.train[inTrain, ]
testing <- data.train[-inTrain, ]

mod1 <- train(classe ~. , method="rpart", data=data.train)


#The code below is for the Random Forest Model.
# Need to do parrellel processing, due to limited RAM
# Uncomment if want to rebuild the model
# Or just load the saved model object

#load mod2 Random Forst model
load("rf_model.rda")

#x <- training[, -46]
#y <- training[, 46]
#library(parallel)#base package
#library(doParallel)
#cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
#registerDoParallel(cluster)
#fitControl <- trainControl(method = "cv",
#                           number = 10,
#                           allowParallel = TRUE)
#mod2 <- train(x,y=make.names(training$classe), method="rf", data=data.train, trControl = fitControl)

#save(mod2, file = "rf_model.rda")

#Compare model accuracy
pred1 <- predict(mod1, testing)
pred2 <- predict(mod2, testing)

confusionMatrix(pred1, testing$classe)
confusionMatrix(pred2, testing$classe)

confusionMatrix(pred1, testing$classe)$overall["Accuracy"]
confusionMatrix(pred1, testing$classe)$overall["AccuracyLower"] #CI
confusionMatrix(pred1, testing$classe)$overall["AccuracyUpper"]

confusionMatrix(pred2, testing$classe)$overall["Accuracy"]
confusionMatrix(pred2, testing$classe)$overall["AccuracyLower"]#CI 
confusionMatrix(pred2, testing$classe)$overall["AccuracyUpper"]


#Predict with new data
predict.new <- predict(mod2, newdata = data.new)
table(predict.new)
predict.new




#Save session info
 #session_info <- sessionInfo()
 #save(session_info, file = "session_info.rda")
 #load("session_info.rda")


# Just for fun
mod3 <- rpart(factor(classe) ~ . , data = training, method = "class")
mod4 <- randomForest(classe ~ . , data = training)
pred3 <- predict(mod3, testing, type = "class")
pred4 <- predict(mod4, testing)
confusionMatrix(pred3, testing$classe)
confusionMatrix(pred4, testing$classe)

table(pred3)

predict.new2 <- predict(mod4, newdata = data.new)
predict.new2
table(predict.new2)

plotcp(mod3)
mod3$cptable

