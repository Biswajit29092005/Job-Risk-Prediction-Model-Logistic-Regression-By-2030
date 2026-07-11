# Dynamic Job Risk Simulator

The Dynamic Job Risk Simulator is an offline Flutter application designed to predict the probability of job displacement. It evaluates an individual's career risk by combining their personal baseline metrics, macroeconomic threat factors, and adaptive competency vectors into a native machine learning pipeline. 

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
