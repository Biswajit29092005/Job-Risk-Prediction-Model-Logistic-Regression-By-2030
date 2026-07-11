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
# Dynamic Labor Risk Simulator

The Dynamic Labor Risk Simulator is an offline Flutter application designed to predict the probability of job displacement. It evaluates an individual's career risk by combining their personal baseline metrics, macroeconomic threat factors, and adaptive competency vectors into a native machine learning pipeline. 

## Application Features

* **Offline Prediction Engine**: The application executes all predictions entirely on the device without requiring an external API, using a local JSON database fallback.
* **Dynamic Industry Taxonomy**: The interface automatically adjusts the labels of 10 core competency sliders based on the target job title entered. It includes customized taxonomies for fields such as security, software engineering, healthcare, construction, education, and management. 
* **Customizable Threat Environment**: Users can simulate external risks by adjusting sliders for the AI Task Exposure Index, Industry Tech Growth Acceleration, and General Job Automation Probability.
* **Modern Interface**: Built using Material 3 design principles, featuring a dark theme utilizing a teal seed color.

## Machine Learning Pipeline

The application processes user input through a strict, multi-step pipeline to generate a final risk status:

* **Feature Vector Assembly**: The app gathers 16 raw features, mapping the user's salary, experience, education, environmental factors, and the 10 skill inputs.
* **Qualification Modifiers**: The user's selected education tier applies a mathematical modifier to their skill inputs, acting as a competency ceiling (e.g., High School multiplies skills by 0.70, while a Master's/Ph.D. multiplies by 1.30).
* **Z-Score Normalization**: The raw features are normalized into z-scores utilizing standard means and standard deviations explicitly extracted from a Python Standard Scaler.
* **Native Model Scoring**: The normalized feature list is passed into a native Dart `score` function. This function computes the log-odds using a linear equation comprising 16 feature weights and a base intercept of 11.87.
* **Probability Output**: The resulting log-odds are converted into a percentage using a sigmoid function. If the displacement probability exceeds 50%, the UI flags the status as "AT RISK" in red; otherwise, it is marked as "SAFE" in teal.

## Code Structure

* `main.dart`: Contains the `JobPredictionApp` root widget defining the application's Material 3 dark theme, and the `OfflinePredictionScreen` stateful widget handling the core UI layout, text controllers, dynamic skill label generation, and normalization logic.
* `model_logic.dart`: The native Dart transpilation of the logistic regression model containing the `score` evaluation function.
