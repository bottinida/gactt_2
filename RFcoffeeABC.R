# Housekeeping
rm(list = ls())
set.seed(123)

#load libraries
library(readxl)
library(randomForest)
library(ggplot2)
library(corrplot)
library(cowplot)
library(tidyverse)
library(class)
library(nnet)
library(gbm)

#load dataset 
gactt_xlsx <- read_excel("CleanGACTT.xlsx")
gactt <- gactt_xlsx[, -c(59:60)]
dim(gactt) # 3972 58
#colSums(is.na(gactt))


#DF structure: Transformations

for (i in 1:40) {
  gactt[[i]] <- as.factor(gactt[[i]])
}
gactt[[41]] <- as.numeric(gactt[[41]])
for (i in 42:58) {
  gactt[[i]] <- as.factor(gactt[[i]])
}
str(gactt)

#barplot
barplot(table(gactt$coffee_preference_ABC), main = "ABC Coffee preference distribution", xlab = "Coffee Preference", ylab = "Frequency", ylim = c(0, 2000))


#correlation matrix
gactt_num <- as.data.frame(lapply(gactt, as.numeric))
cor_matrix <- cor(gactt_num)
corrplot(cor_matrix, method = "ellipse")


## Split to training and testing subset 
split_gactt <- sort(sample(3972,1191, replace = FALSE)) 
coffeetrain <- gactt[-split_gactt,] 
coffeetest <- gactt[split_gactt,]
dim(coffeetest)
dim(coffeetrain)

## Extra the true response value for training and testing data
y1    <- coffeetrain$coffee_preference_ABC; 
y2    <- coffeetest$coffee_preference_ABC; 


#random forest with all predictors, default parameters and "coffee_preference_ABC" as response 
rf.roast <- randomForest(coffee_preference_ABC ~., data=coffeetrain, importance = TRUE)
rf.roast

## Prediction on the testing data set
rf.pred = predict(rf.roast, coffeetest, type='class') 
table(rf.pred, y2)


missc_roast <- mean(rf.pred != y2 )
missc_roast


## Check Important variables
importance(rf.roast)
## There are two types of importance measure 
##  (1=mean decrease in accuracy, 
##   2= mean decrease in node impurity)
importance(rf.roast, type=2)
varImpPlot(rf.roast)

#Test better parameters
oob.error.data <- data.frame(
Trees=rep(1:nrow(rf.roast$err.rate), times=4),
Type=rep(c("Coffee A", "Coffee B", "Coffee C", "No stated preference"), each=nrow(rf.roast$err.rate)),
Error=c(rf.roast$err.rate[,"Coffee A"], 
        rf.roast$err.rate[,"Coffee B"], 
        rf.roast$err.rate[,"Coffee C"],
        rf.roast$err.rate[,"No stated preference"]))

gg <- ggplot(data=oob.error.data, aes(x=Trees, y=Error)) +
  geom_line(aes(color=Type))+
  labs(title = "Out-of-bag (OOB) error graph for random forest estimation (number of trees)") +
  theme_minimal()
gg

#Evaluate where ntree stabilizes
oob_errors <- vector()
ntree_values <- seq(200, 400, by = 10)

#Training models with different ntree values and calculate OOB error 
for (ntree in ntree_values) {
  rf_model <- randomForest(coffee_preference_ABC ~., data=coffeetrain, ntree = ntree) 
  oob_error <- rf_model$err.rate[nrow(rf_model$err.rate), "OOB"]
  oob_errors <- c(oob_errors, oob_error)
}

#Plot where ntree stabilizes
plot(ntree_values, oob_errors, type = "b", xlab = "Number of Trees (ntree)", ylab = "OOB Error ", main = "OOB Error")

#Ntree value that minimizes OOB error
best_ntree <- ntree_values[which.min(oob_errors)]
cat("Best ntree value is:", best_ntree, "\n") #390


#Evaluate best value for mtry
oob.values <- vector(length=10)
for(i in 1:10) {
  temp.model <- randomForest(coffee_preference_ABC ~., data=coffeetrain, mtry=i, ntree=best_ntree)
  oob.values[i] <- temp.model$err.rate[nrow(temp.model$err.rate),1]
}
oob.values
# find the minimum error
min(oob.values)
# find the optimal value for mtry...
best_mtry <- which(oob.values == min(oob.values))
# create a model for proximities using the best value for mtry
model <- randomForest(coffee_preference_ABC ~., data=coffeetrain,
                      ntree=best_ntree, 
                      mtry=best_mtry,
                      )
model


## Prediction on the testing data set

rf.pred2 = predict(model, coffeetest, type='class') 
table(rf.pred2, y2)

missclassification <- mean(rf.pred2 != y2 )
missclassification

## Second Analysis

#DATA CLEANING
gactt$Age <- as.factor(gactt$Age)
gactt$DailyCups <- as.factor(gactt$DailyCups)
char_columns <- colnames(gactt[,sapply(gactt,is.character)])
logi_columns <- colnames(gactt[,sapply(gactt,is.logical)])

for (col in char_columns){
  gactt[[col]] <- as.factor(gactt[[col]])
}

for (col in logi_columns){
  gactt[[col]] <- as.factor(gactt[[col]])
}

str(gactt)

ds_length <- dim(gactt)[1]

flag <- sort(sample(ds_length,ds_length*0.3, replace = FALSE))
gactt_train <- gactt[-flag,]
gactt_test <- gactt[flag,]

#labels
labels_train <- gactt_train$coffee_preference_ABC
labels_test <- gactt_test$coffee_preference_ABC
train_data_feats <- gactt_train %>% select(-coffee_preference_ABC)
gactt_test_model <- gactt_test %>% select(-coffee_preference_ABC)

#-------------Multinomial------------------
model_mm <- multinom( coffee_preference_ABC ~ ., data = gactt_train)

length(labels_test)
dim(gactt_test_model)

#training error

predictions_mm <- predict(model_mm, newdata = train_data_feats)
predictions_mm
table(predictions_mm,labels_train)
terr_mm <- mean(predictions_mm != labels_train)
terr_mm # [1] 0.1708019

predict_mm_test <- predict(model_mm, newdata = gactt_test_model)
predict_mm_test

table(predict_mm_test,labels_test)
testerr_mm <- mean(predict_mm_test != labels_test)
testerr_mm

# ------------------------SVM---------
library(e1071)

# Fit SVM model
model_svm <- svm(coffee_preference_ABC ~ ., data = gactt_train)

summary(model_svm)
model_svm$cost #1
model_svm$gamma # 0.005952381

#Training Error untuned
predictions_svm <- predict(model_svm, newdata = train_data_feats)
predictions_svm
table(predictions_svm,labels_train)
terr_svm <- mean(predictions_svm != labels_train)
terr_svm

#training error is: [1] [1] 0.1895002

#Testing error untuned
pred_usvm_test <- predict(model_svm, newdata = gactt_test_model)
pred_usvm_test
table(pred_usvm_test,labels_test)
testerr_usvm <- mean(pred_usvm_test != labels_test)
testerr_usvm #[1] 0.1889169


# TUNING SVM

tune_out <- tune(svm,coffee_preference_ABC ~ .,data = gactt_train,
                 ranges = list(cost = c(0.1,1,10,100,1000), gamma = 10^(-3:3)))

best_model <- tune_out$best.model
summary(best_model)

tune_out$best.parameters$cost #cost =10
tune_out$best.parameters$gamma #[1] 0.001


#predictions for train data
pred_svm_train <- predict(best_model, newdata = train_data_feats)
miss_svm_rate_train <- mean(pred_svm_train != labels_train)
miss_svm_rate_train #training error [1] 0.1891406
table(pred_svm_train,labels_train)


#predictions for test data
predictions_svm2 <- predict(best_model, newdata = gactt_test_model)
miss_svm_rate2 <- mean(predictions_svm2 != labels_test)
miss_svm_rate2 #[1] 0.1889169

#---------------- Boosting ----------------------

#using GBM
gbm_abc <- gbm(coffee_preference_ABC ~ ., data = gactt_train,
               distribution = 'multinomial',
               n.trees = 5000,
               shrinkage = 0.01,
               interaction.depth = 3,
               cv.folds = 10)


perf_gbm1 = gbm.perf(gbm_abc, method="cv")
perf_gbm1
summary(gbm_abc)


# Training Error
pred1gbm <- predict(gbm_abc,newdata = train_data_feats, n.trees=perf_gbm1,
                    type="response")
length(labels_train)

pred1gbm
labels_train
y1hat <- ifelse(pred1gbm < 0.5, 0, 1)
y1hat


new_labels <- apply(y1hat,c(1, 3), function(x) {
  switch(which.max(x),
         "Coffee A",
         "Coffee B",
         "Coffee C",
         "No stated preference")})

new_labels <- as.factor(new_labels)
sum(new_labels != labels_train)/length(labels_train) ##Training error = [1] 0.1837469
corr_matrix <- cor(gactt)

#testing error
pred_boost_test <- predict(gbm_abc, newdata = gactt_test_model)

y1hat_test <- ifelse(pred_boost_test < 0.5, 0, 1)

new_labels_test <- apply(y1hat_test,c(1, 3), function(x) {
  switch(which.max(x),
         "Coffee A",
         "Coffee B",
         "Coffee C",
         "No stated preference")})


new_labels_test <- as.factor(new_labels_test)
testerr_boost <- mean(new_labels_test != labels_test)
testerr_boost #0.1847187

