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
There are 4 main steps in this analysis: initial setup, data pre-processing, data modelling, and output preparation. Prediction accuracy is evaluated using multi-class logarithmic loss. Each data row has been labeled with one true class. 
<br>

<b>RESULT/CONCLUSION</b><br>
result.csv is a file consisted of a set of test row id and probability for all 3 classes of fault fault severity. 
<br>

<b>LESSON(S) LEARNED</b>
