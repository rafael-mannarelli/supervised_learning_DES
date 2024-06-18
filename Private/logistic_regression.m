function [predictions, testLabel, testFeatures, theta] = logistic_regression(features, label, percentageTrainingData)

    % This function performs Logistic Regression on a given dataset using
    % Gradient Descent. It splits the dataset into training and test sets,
    % trains the model on the training set, and then makes predictions on the test set.

    % Inputs:
    % features - The features for LR
    % label - A column vector containing binary labels for each instance
    % percentageTrainingData - A scalar value representing the percentage of data to be used for training

    % Outputs:
    % predictions - A vector containing predicted probabilities for the test set
    % testLabel - The actual labels for the test dataset
    % testFeatures - The features of the test dataset
    % theta - The learned parameters of the Logistic Regression model

    % The Logistic Regression model is trained to predict the probability
    % of a binary outcome (1 or 0) based on the input features. The model's
    % effectiveness is determined by how well it performs on the unseen test data.

%% Logistic Regression using Gradient Descent

% Calculate the number of rows to select for the training data (80%)
nbRows = round(percentageTrainingData * size(features, 1));

% Generate a vector of unique random indices
randomIndex = randperm(size(features, 1));

% Select the first 80% of rows as training data
trainFeatures = features(randomIndex(1:nbRows), :);
trainLabel = label(randomIndex(1:nbRows), :);

% Select the remaining 20% as testing data
testFeatures = features(randomIndex(nbRows+1:end), :);
testLabel = label(randomIndex(nbRows+1:end), :);

% Input data for training
X = trainFeatures; % Feature matrix (each row represents a sequence of events)
y = trainLabel;    % Label vector (0 for non-controllable, 1 for controllable)

% Number of examples and features
[m, n] = size(X);

% Add a column of 1s to represent the intercept term (bias)
X = [ones(m, 1), X];

% Initialize model parameters (theta) with zeros
theta = zeros(n + 1, 1);

% Define the sigmoid function
sigmoid = @(a) 1 ./ (1 + exp(-a));

% Define the cost function (logarithmic loss)
cost = @(theta) (-1 / m) * sum(y .* log(sigmoid(X * theta)) + (1 - y) .* log(1 - sigmoid(X * theta)));

% Define the gradient of the cost function
gradient = @(theta) (1 / m) * X' * (sigmoid(X * theta) - y);

% Set the learning rate and the number of iterations for gradient descent
alpha = 0.1;        % Learning rate
numIterations = 1000;  % Number of iterations

% Gradient Descent: Update theta iteratively
for iter = 1:numIterations
    theta = theta - alpha * gradient(theta);
end

% Prediction on new data
newFeatures = testFeatures;
newFeatures = [ones(size(newFeatures, 1), 1), newFeatures];
predictions = sigmoid(newFeatures * theta);
