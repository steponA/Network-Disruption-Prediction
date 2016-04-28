# --------------------------------------------------------------------------------
# INITIAL SETUP
# --------------------------------------------------------------------------------
# setwd  

# load library
library(DataCombine) # for slide function
library(data.table)
library(tidyr)
library(xgboost)

# load supplementary data sets
feature <- read.csv("log_feature.csv")
event <- read.csv("event_type.csv")
resource <- read.csv("resource_type.csv")
severity <- read.csv("severity_type.csv")

# load main data sets
train <- read.csv("train.csv")
test <- read.csv("test.csv")

# load sample_submission set
sample_submission <- read.csv("sample_submission.csv")

# combine data sets
X_train <- train
X_test <- test
X_test$fault_severity <- NA
X_comb <- rbind(X_train,X_test)

# match order of id in X_comb set with order of supplementary sets
X_comb <- X_comb[match(severity$id, X_comb$id), ]

# rename location column to loc
names(X_comb)[names(X_comb) == "location"] <- "loc"

# rename fault_severity column to FS
names(X_comb)[names(X_comb) == "fault_severity"] <- "FS"

# --------------------------------------------------------------------------------
# DATA PRE-PROCESSING: COMBINED DATA
# --------------------------------------------------------------------------------
# change categorical location data into numerical data
# X_comb$loc <- as.numeric(gsub("location ", "", X_comb$loc))

# new feature: location count
locCount <- data.frame(table(X_comb$loc))
names(locCount)[1] <- "loc"
names(locCount)[2] <- "locCount"

# merge location count in X_comb set
X_comb <- merge(X_comb, locCount, by = "loc")

# spread location from long to wide format
X_location  <- dcast(X_comb, id ~ loc, length, value.var = "id", fill = 0)

# merge X_comb with X_location set
X_comb <- merge(X_comb, X_location, by = "id")

# --------------------------------------------------------------------------------
# DATA PRE-PROCESSING: SEVERITY
# --------------------------------------------------------------------------------
# merge location and severity types
X_comb <- merge(X_comb, severity)
X_comb <- X_comb[match(severity$id, X_comb$id), ]

# new feature: locAsc (ascending rank for each location)
X_comb$locAsc <- seq(nrow(X_comb)) 

# new feature locDesc (descending rank for each location)
X_comb$locDesc <- rank(-(X_comb$locAsc))

# rename severity_type column to ST
names(X_comb)[names(X_comb) == "severity_type"] <- "ST"

# rename severity_type in observations to ST_
X_comb$ST <- gsub(pattern = "severity_type",
                  replacement = "ST_",
                  x = X_comb$ST)

# new features: lag feature of fault severity for 1-10 spots before current id
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 1)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 2)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 3)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 4)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 5)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 6)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 7)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 8)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 9)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = 10)

# new features: lead feature of fault severity for 1-10 spots after current id
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -1)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -2)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -3)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -4)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -5)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -6)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -7)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -8)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -9)
X_comb <- slide(X_comb,
                Var = "FS",
                slideBy = -10)


# --------------------------------------------------------------------------------
# DATA PRE-PROCESSING: EVENT
# --------------------------------------------------------------------------------
# spread from long format to wide format
X_event <- event
names(X_event)[2] <- "ET"
X_event$ET <- gsub("event_type ", "ET_", X_event$ET)
X_event <- dcast(X_event, id ~ ET, length, value.var = "id", fill = 0)

# match id in order of X_comb set
X_event <- X_event[match(X_comb$id, X_event$id), ]

# new feature: sum of events per id
X_event$ET_sum <- rowSums(X_event[ ,c(2:54)])

# --------------------------------------------------------------------------------
# DATA PRE-PROCESSING: RESOURCE
# --------------------------------------------------------------------------------
X_resource <- resource
names(X_resource)[2] <- "RT"
X_resource$RT <- gsub("resource_type ", "RT_", X_resource$RT)

# spread from long to wide format so one id per row
X_resource <- dcast(X_resource, id ~ RT, length, value.var = "id", fill = 0)

# match id in order of X_comb set
X_resource <- X_resource[match(X_comb$id, X_resource$id), ]

# new feature: RT_sum (sum of resources per id)
X_resource$RT_sum <- rowSums(X_resource[ ,c(2:11)])


# --------------------------------------------------------------------------------
# DATA PRE-PROCESSING: FEATURE
# --------------------------------------------------------------------------------
# X_feat <- feature
X_feature <- feature

# change categorical feature data into numerical data
# X_feat$log_feature <- as.numeric(gsub("feature ", "", X_feat$log_feature))
# X_feat$volume <- NULL

# change long format to wide format so id per row
X_feature$log_feature <- gsub("feature ", "F_", X_feature$log_feature)
X_feature <- spread(X_feature, log_feature, volume)
# X_feature[is.na(X_feature)] <- 0
X_feature <- X_feature[match(X_comb$id, X_feature$id), ]

# new column: sum of volume of each id
X_feature$F_sum <- rowSums(X_feature[ ,c(2:387)], na.rm = T)

# new column: mean value of feature volume of each id
X_feature$F_mean <- rowMeans(X_feature[ ,c(2:387)], na.rm = T)

# new column: min value of feature volume of each id
X_feature$F_min <- apply(X_feature[ ,2:387], 1, min, na.rm = T)

# new column: max value of feature volume of each id
X_feature$F_max <- apply(X_feature[ ,2:387], 1, max, na.rm = T)

# new column: median value of feature volume of each id
X_feature$F_median <- apply(X_feature[ ,2:387], 1, median, na.rm = T)

# assign 0 to NA values in X_feature set
X_feature[is.na(X_feature)] <- 0

# --------------------------------------------------------------------------------
# DATA PRE-PROCESSING: CONCATENATE DATASETS
# --------------------------------------------------------------------------------
Z_comb <- merge(X_comb, X_event, by = "id")
Z_comb <- merge(Z_comb, X_feature, by = "id")
Z_comb <- merge(Z_comb, X_resource, by = "id")
Z_comb <- Z_comb[match(X_comb$id, Z_comb$id), ]

# --------------------------------------------------------------------------------
# DATA PRE-PROCESSING: MAGIC FEATURE
# --------------------------------------------------------------------------------
mloc = 1
for(i in 1:(nrow(Z_comb)-1))
{ 
        Z_comb$mloc[i] = mloc
        if(Z_comb$loc[i] == Z_comb$loc[i+1])
                mloc = mloc+1
        else
                mloc = 1
        Z_comb$mloc[i+1]= mloc
}

# --------------------------------------------------------------------------------
# DATA PRE-PROCESSING: SEPERATE DATASETS INTO TRAIN AND TEST
# --------------------------------------------------------------------------------
Z_train <- subset(Z_comb, !is.na(Z_comb$FS))
Z_test <- subset(Z_comb, is.na(Z_comb$FS))

# --------------------------------------------------------------------------------
# DATA MODELLING
# --------------------------------------------------------------------------------
# ensure repeatable result
set.seed(2)

# keep record of test id column for final output
id = Z_test[ ,1]

# set modelling target
target = Z_train$FS
classnames = unique(target)

# remove variables not to be included in modelling
trainFeat = Z_train[ ,-c(1,3)]
testFeat = Z_test[ ,-c(1,3)]

# convert categorical location data into numeric
trainFeat$loc <- as.numeric(gsub("location ", "", trainFeat$loc))
testFeat$loc <- as.numeric(gsub("location ", "", testFeat$loc))

# convert dataset into numeric Matrix format, which is preferred in XGBoost
# trainFMatrix <- as.matrix(sapply(trainFeat, as.numeric))
trainMatrix <- data.matrix(trainFeat)
trainMatrix <- scale(trainMatrix)
testMatrix <- data.matrix(testFeat)
testMatrix <- scale(testMatrix)

# cross-validation
modelXGB_cv <- xgb.cv(data = trainMatrix,
                      label = as.matrix(target),
                      num_class = 3,
                      nfold = 10,
                      objective = "multi:softprob",
                      nrounds = 1600,
                      eta = 0.01,
                      max_depth = 8,
                      subsample = 0.9,
                      colsample_bytree = 0.5,
                      eval_metric = "mlogloss",
                      prediction = T,
                      missing = NaN)

# note: takes 3hours 3min to run
# return: CV score of 0.451878

# make prediction model
modelXGB <- xgboost(data = trainMatrix,
                    label = as.matrix(target),
                    num_class = 3,
                    objective = "multi:softprob",
                    nrounds = 1600,
                    eta = 0.01,
                    max_depth = 8,
                    subsample = 0.9,
                    colsample_bytree = 0.5,
                    eval_metric = "mlogloss",
                    missing = NaN)

# note: takes 20 min to run

# predict target
ypred = predict(modelXGB, testMatrix, missing = NaN)


# --------------------------------------------------------------------------------
# OUTPUT PREPARATION
# --------------------------------------------------------------------------------
predMatrix <- data.frame(matrix(ypred,ncol = 3,byrow = T))
colnames(predMatrix) = classnames
result <- data.frame(id,predMatrix)

# match order of result id to match order of sample submission id
result <- result[match(sample_submission$id, result$id), ]

# rename columns
names(result)[2] <- "predict_0"
names(result)[3] <- "predict_1"
names(result)[4] <- "predict_2"

# print result in csv format for submission
write.csv(result,'iteration15.csv',row.names = F)

# notes on result feedback:
# public leaderboard score: 0.45538
# private leaderboard score: 0.45956
# top 9% in the competition (78th position out of 924 competitors)
