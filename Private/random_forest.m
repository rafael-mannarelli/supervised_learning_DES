function [predictLabel, testLabel, testFeatures, model] = random_forest(features, label, percentageTrainingData)

    % This function trains a Random Forest classifier on the provided dataset
    % and evaluates its performance on a test set.

    % Inputs:
    % features - The features of RF (same as LR)
    % label - A matrix of binary labels for each instance (each column represents a different label)
    % percentageTrainingData - A scalar value representing the percentage of data to be used for training

    % Outputs:
    % predictLabel - Predicted labels for the test data
    % testLabel - Actual labels for the test data
    % testFeatures - Features of the test data
    % model - A cell array containing trained Random Forest models for each label

    % The function uses the TreeBagger class in MATLAB for Random Forest training,
    % capable of handling multi-label classification tasks, where each instance
    % might belong to more than one class.

model = cell(size(label, 2), 1);
predictLabel = [];
testLabel = [];
testFeatures = [];

for i = 1:size(label, 2)
    %% Step 1: Initialization

    X = features;
    Y = label(:, i);

    % Split your data into training and testing sets
    trainRatio = percentageTrainingData; % Training data ratio
    validationRatio = 1 - trainRatio; % Validation data ratio

    % Calculate split indices
    numObservations = size(X, 1);
    numTrain = round(trainRatio * numObservations);
    numValidation = round(validationRatio * numObservations);
    index = randperm(numObservations);

    % Training data
    XTrain = X(index(1:numTrain), :);
    YTrain = Y(index(1:numTrain));

    % Validation data
    XValidation = X(index(numTrain + 1:numTrain + numValidation), :);
    YValidation = Y(index(numTrain + 1:numTrain + numValidation));

    %% Step 2: Train the Random Forest model

    % Define Random Forest hyperparameters
    numTrees = 200; % Number of trees in the Random Forest

    % Train the Random Forest model
    model(i) = {TreeBagger(numTrees, XTrain, YTrain, 'Method', 'classification', 'Options', statset('UseParallel', true))};

    %% Step 3: Model Evaluation

    % Predict on validation data
    YValidationPredicted = predict(model{i}, XValidation);

    predictLabel = [predictLabel, YValidationPredicted];
    testLabel = [testLabel, YValidation];
    testFeatures = [testFeatures, XValidation];

end
end