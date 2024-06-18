# Supervised Learning for Supervisory Control of Discrete-Event Systems

## Abstract
This project integrates supervised learning techniques with Supervisory Control Theory (SCT) to enhance the control mechanisms of Discrete-Event Systems (DES) in complex and unpredictable environments. By applying Logistic Regression, LSTM networks, and Random Forest models, this project aims to develop a data-driven approach to supervisory control, leveraging MATLAB and the MatlabTCT toolkit for implementation.

## Introduction
The project addresses the increasing complexity and evolving nature of modern discrete-event systems such as manufacturing lines and transportation systems, which demand a shift from conventional model-based control strategies to more adaptive, data-driven solutions.

## Code Structure
- **Parameter Initialization**: Set parameters like mean Gaussian, sigma values, etc.
- **User Interface Setup**: Configure options for random number generation, machine learning algorithm selection, and label type selection.
- **Data Pre-processing**: Includes functions like `parser_des`, `parser_dat`, and `sup_to_data` for preparing the data for subsequent machine learning tasks.
- **Label Generation**: Functions like `label_control_data`, `label_event_prediction`, and `label_marker` to create appropriate labels for machine learning training.
- **Feature Extraction**: Functions `data_for_LR` and `data_for_RNN` prepare features for Logistic Regression and Recurrent Neural Networks, respectively.
- **Machine Learning Models**: Implementations of logistic regression, recurrent neural networks (LSTM), and random forest models for classification tasks.

## Setup and Running
1. **Environment Setup**: Ensure MATLAB R2023a and MatlabTCT toolkit are installed.
2. **Clone the Repository**: `git clone https://github.com/rafael-mannarelli/supervised_learning_DES`
3. **Navigate to the Project**: `cd path_to_project`
4. **Execute Main Script**: Run the main MATLAB script to initiate the program.

## Validation and Results
The system's performance is validated through accuracy metrics calculated against test datasets, demonstrating the efficacy of the integrated machine learning models.

## Conclusion
This project provides a robust framework for exploring the potential of machine learning in enhancing the supervisory control of discrete-event systems, suitable for researchers and practitioners looking to incorporate data-driven techniques into their control strategies.

## References
- W. M. Wonham and K. Cai. Supervisory Control of Discrete-Event Systems. Communications and Control Engineering. Springer, 2018.
