# Network-Disruption-Prediction

<b>CONTEXT</b><br>
An anonymized telecommunication company is working on improving its customer satisfation. One way to do so is by predicting the scope and timing of service disruption to help better serve its customers. 
<br>

<b>OBJECTIVE</b><br>
Predict if the disruption, at a particular time and location, is a momentary glitch or a total interruption of connectivity. The disruption fault severity is assigned with 3 categories: 0 meaning no fault, 1 meaning only a few, 2 meaning many faults. 
<br>

<b>DATA DESCRIPTION</b><br>
train.csv and test.csv are the main datasets. <br>
event_type.csv, log_feature.csv, resource_type.csv, and severity_type.csv are the supplementary datasets. <br>
sample_submission.csv provides a sample submission file in the correct format.
<br>

<b>ANALYSIS PROCESSS</b><br>
analysis.R is a script written in R programming language. <br>
There are 4 main steps in this analysis: initial setup, data pre-processing, data modeling, and output preparation. <br>
1. Initial setup is mainly concerned with setting the working directory, loading R packages and data sets, and combining datasets. <br>
2. In data pre-processing: data sets such as event_type, log_feature, and resource_type are reshaped from long to wide format so that the newly-formed set contains one id and all its corresponding variables/characteristics in one row (one-to-many). Then, features engineering were applied to uncover the pattern of time as it is not explicitly provided. Combined dataset can now be divided into 2 parts of train and test set again before model is formed in the next step. <br>
3. Data modeling is built on XGBoost package. Prediction accuracy is evaluated using multi-class logarithmic loss. Target to be predicted on test set is made here. <br>
4. In output preparation, new data frame is created, following the format of sample_submission, to contain test set target prediction.

<b>RESULT/CONCLUSION</b><br>
result.csv is a file consisted of a set of test row id and probability for all 3 classes of fault fault severity. 
Cross-validation on my local machine is 0.451878, while the public leaderboard score is 0.45538 and the private leaderboard score is 0.45956. In the competition, it was ranked 78th of of 924 competitors (top 9%). 
<br>

<b>LESSON(S) LEARNED</b>
As a beginner, I learned a lot from this challenge such as combining/separating and reshaping data set and using xgboost. This size of data set is relatively small that it is manageable for me to trial and error. But the most challenging part for me is figuring out the time pattern, which I uncovered through feature engineering. The model I built is actually a simple one, with very minimal finetuning. So this is also an area I would like to improve. 
