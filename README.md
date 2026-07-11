# Job Loss Risk Prediction Model

This repository contains a Machine Learning pipeline for a Binary Classifier designed to predict job loss risk. It evaluates whether a job role is "Safe" (0) or "At Risk" (1) based on various industry and technological factors.

## Dataset and Preprocessing
* The model utilizes an initial dataset of 3,000 records.
* Data cleaning involves dropping missing values and removing duplicates.
* The target variable, `Risk_Category`, is converted into a binary format where 'Low' becomes 0 and 'Medium'/'High' becomes 1.
* Categorical variables are transformed into numerical formats using `LabelEncoder`.
* Features are scaled using `StandardScaler` to achieve a mean of 0 and variance of 1.

## Model Architecture
* **Algorithm**: Logistic Regression configured with the `lbfgs` solver, balanced class weights, and a maximum of 1000 iterations.
* **Data Split**: The data is split into 70% for training and 30% for testing.

## Evaluation Metrics
The model demonstrates exceptional stability and accuracy in identifying risk:
* **Cross-Validation**: Achieved a Mean Accuracy of 0.9738 with a standard deviation of 0.0077.
* **Overall Accuracy**: 97.56% on the test set.
* **Recall (True Positive Rate)**: 0.97 (97%).
* **Error Rate**: The model made 22 mistakes out of 900 test samples, resulting in a 2.44% error rate.

### Specificity Calculation
To evaluate the false positive rate rigorously, specificity is calculated directly from the extracted confusion matrix values.
* **True Negatives (TN)**: 225
* **False Positives (FP)**: 0
* **Calculated Specificity**: 1.0 (100%), meaning the model correctly identified all 'Safe' jobs in the test set without a single false positive.

## Export and Mobile Integration
This model is prepared for cross-platform implementation:
* A standard Python model file is exported as `job_loss_model.pkl` using `joblib`.
* To facilitate mobile application development, the base Logistic Regression model is transpiled directly to Dart code (`model_logic.dart`) using the `m2cgen` library.
* The `StandardScaler` mean and scale arrays are extracted for manual implementation within the Dart environment to ensure consistent feature scaling.
