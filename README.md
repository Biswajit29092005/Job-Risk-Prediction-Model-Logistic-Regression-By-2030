# Job Lose Prediction Model

## Overview
This project is a binary classification machine learning model designed to predict the risk of job loss. It evaluates various professional metrics, including AI exposure, tech growth factors, and automation probability, to classify jobs as either "Safe" (0) or "At Risk" (1). 

## Dataset
The dataset (`data.csv`) consists of 3,000 records with features detailing job characteristics and vulnerability to automation. 
Key features include:
* `Job_Title`
* `Average_Salary`
* `Years_Experience`
* `Education_Level`
* `AI_Exposure_Index`
* `Tech_Growth_Factor`
* `Automation_Probability_2030`

## Methodology
* **Data Preprocessing:** Categorical variables were encoded, and numerical features were standardized using `StandardScaler`. The pipeline was strictly ordered (split before scaling) to prevent data leakage.
* **Model Selection:** Logistic Regression was utilized as the baseline binary classifier.
* **Validation:** 5-fold Cross-Validation was implemented to ensure the model's stability and generalization to unseen data.

## Performance Metrics
The model was evaluated on a 30% holdout test set (900 samples) and achieved exceptional results:
* **Overall Accuracy:** 98%
* **Cross-Validation Mean Accuracy:** 98.00% (Standard Deviation: 0.0063)
* **Specificity (True Negative Rate):** 1.0 (100%) - The model generated zero false positives for the 'Safe' class.
* **Recall (True Positive Rate):** 0.97 (97%) - The model successfully identified 97% of all actual 'At Risk' instances.

## Files in this Repository
* `Job Lose Prediction Model.ipynb`: The Jupyter Notebook containing the full data pipeline, model training, and evaluation.
* `data.csv`: The dataset used to train and test the model.

## How to Run
1. Clone this repository.
2. Ensure you have Python installed along with `pandas`, `numpy`, `matplotlib`, `seaborn`, and `scikit-learn`.
3. Open `Job Lose Prediction Model.ipynb` in Jupyter Notebook or JupyterLab.
4. Run the cells sequentially to reproduce the model and metrics.
