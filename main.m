%% Clear and close everything
clear all; close all; clc;

%% Path
addpath(genpath('.'));

%% Parameters
meanGaussian = 25; % Gaussian mean
sigma = 3; % Gaussian standard deviation
minU = 1; % Minimum of uniform distribution
maxU = 50; % Maximum of uniform distribution
sizeSampling = 500; % Sampling size
percentageTrainingData = 0.8; % Percentage taken for the training data of the sample data

%% User interface
randomType = 'Uniform'; % 'Uniform' or 'Gaussian', choose between both distributions

MLType = 'LR'; % 'LR', 'LSTM', or 'RF', choose between available machine learning algorithms

labelType = 'CD'; % 'CD' for control data, 'Marker' for marker state, 'Event+1' for event prediction; choose between labels for prediction

example = 'EX_RA';  % Choose an example

if strcmp('EX_ORDER', example)

    % Initialize parameters
    m = sizeSampling;   % Initialize m with a predefined value
    n = 5;               % Set the value of n to 5
    dataEvent = zeros(m, n);  % Initialize dataEvent as an m x n matrix of zeros
    labelControlData = zeros(m, 1);  % Initialize labelControlData as an m x 1 matrix of zeros
    
    % Generate random permutations for each row in dataEvent
    for i = 1:m
        dataEvent(i, :) = randperm(n, n);  % Generate a random permutation of numbers 1 to n
    end
    
    % Iterate through each row of dataEvent
    for i = 1:m
        % Get the value of the first element in the current row of dataEvent
        firstEvent = dataEvent(i, 1);
        
        % Check if the first event is equal to 2 or 4
        if firstEvent == 2 || firstEvent == 4
            % If it is, set the corresponding element in labelControlData to 1
            labelControlData(i, 1) = 1;
        end
    end
    
    labelChoose = labelControlData;
    dataEventChoose = dataEvent;
    event = transpose(unique(dataEvent(dataEvent > 0)));
else
    %% Parsing
    outputPath = ['data\', example, '\parse_data\'];
    mkdir(outputPath);

    if strcmp('EX_AGV', example)
        nameSUPFile = 'ZWSISSUP';
        nameCAFile = 'ZWSISSUP_CA';
    else
        nameSUPFile = 'SUP';
        nameCAFile = 'SUPDAT_CA';
    end

    % Parse .des file
    fileDes = ['data\', example, '\', nameSUPFile, '.txt'];
    parser_des(fileDes, 'SUP', outputPath);
    fileTransitions = [outputPath, 'SUP_transitions.txt'];
    fileMarker = [outputPath, 'SUP_marker_states.txt'];

    % Parse .dat file
    fileDat = ['data\', example, '\', nameCAFile, '.txt'];
    parser_dat(fileDat, 'SUP_CA', outputPath);
    fileControlData = [outputPath, 'SUP_CA_control_data.txt'];

    %% Import data
    dataTransitions = readmatrix(fileTransitions);
    dataMarker = readmatrix(fileMarker);
    dataControlData = importdata(fileControlData);

    clear fileTransitions fileMarker fileControlData fileDat fileDes

    %% Data from supervisor to dataEvent and position list
    [dataEvent, posList, dataEndPos] = sup_to_data(dataTransitions, dataMarker, meanGaussian, sigma, maxU, minU, randomType, sizeSampling);

    event = transpose(unique(dataEvent(dataEvent > 0)));

    if strcmp('CD', labelType)
        %% Label for control data
        [labelControlData, controlEvent, controlList] = label_control_data(dataControlData, dataEndPos);
        labelChoose = labelControlData;
        dataEventChoose = dataEvent;
    elseif strcmp('Marker', labelType)
        %% Label for marker state
        [labelMarker] = label_marker(dataMarker, dataEndPos);
        labelChoose = labelMarker;
        dataEventChoose = dataEvent;
    else
    end
end

if strcmp('CD', labelType) || strcmp('Marker', labelType)
    if strcmp('LSTM', MLType)
        numClasses = 2; % Number of output classes for LSTM

        %% Data for LSTM
        [xRNN, yRNN] = data_for_RNN(dataEventChoose, event, labelChoose);
        if strcmp('EX_RA', example) && strcmp('CD', labelType)
            indexZeros = find(all(yRNN == 0, 2));
            yRNN(indexZeros, :) = [];
            xRNN(indexZeros, :) = [];
        else
        end

        %% Learning for LSTM
        [predictLabel, testLabel] = recurrent_neural_network(xRNN, yRNN, percentageTrainingData, event, numClasses);
        
        %% Validation for LSTM
        accuracy = [];
        for i = 1:size(yRNN, 2)
            accuracy = [accuracy, sum(predictLabel{:, i} == categorical(testLabel{:, i})) / numel(testLabel{:, i})];
        end
        disp(['Accuracy: ', num2str(accuracy)]);
    
    elseif strcmp('LR', MLType)
        
        %% Data for Logistic regression
        if strcmp('EX_ORDER', example)
            features = zeros(m, n);
            for i = 1:m
                sequence = dataEvent(i, :);
                
                % Iterate over unique events
                for j = 1:length(event)
                    featuresEvent = event(j);
                    occurrence = sum(sequence == featuresEvent);
                    features(i, featuresEvent) = occurrence;
                end
            end
        else
            [features] = data_for_LR(dataEventChoose, dataTransitions);
        end
        if strcmp('EX_RA', example) && strcmp('CD', labelType)
            indexZeros = find(all(labelChoose == 0, 2));
            labelChoose(indexZeros, :) = [];
            features(indexZeros, :) = [];
        else
        end
        %% Learning with Logistic Regression
        nbIteration = 100;
        accuracy = [];
        bestAccuracy = 0;

        for i = 1:nbIteration
            [predictions, testLabel, testFeatures, theta] = logistic_regression(features, labelChoose, percentageTrainingData);
        
        %% Validation for Logistic Regression
            % Decision threshold
            threshold = 0.5;
        
            % Classification layer 
            predictLabel = zeros(size(predictions));
            predictLabel(predictions >= threshold) = 1;
            predictLabel = logical(predictLabel);

            % Calculation of the accuracy
            accuracy = [accuracy; mean(testLabel == predictLabel)]; 

            % Save the best predictions
            if bestAccuracy < accuracy(i)
                bestAccuracy = accuracy(i);
                bestNetwork = theta;
                indexBestPredictions = i;
            else
            end
        end
        
        disp('Mean of the accuracy:');
        meanAccuracy = mean(accuracy);
        disp(meanAccuracy);
        
        disp('Worst accuracy:');
        minAccuracy = min(accuracy);
        disp(minAccuracy);
        
        disp('Best accuracy:');
        maxAccuracy = max(accuracy);
        disp(maxAccuracy);
        
        disp('Range of the accuracy:')
        rangeAccuracy = range(accuracy);
        disp(rangeAccuracy);
     elseif strcmp('RF', MLType)
        %% Data for Random Forest
        if strcmp('EX_ORDER', example)
            features = zeros(m, n);
            for i = 1:m
                sequence = dataEvent(i, :);
                
                % Iterate over unique events
                for j = 1:length(event)
                    featuresEvent = event(j);
                    occurrence = sum(sequence == featuresEvent);
                    features(i, featuresEvent) = occurrence;
                end
            end
        else
            [features] = data_for_LR(dataEventChoose, dataTransitions);
        end
        if strcmp('EX_RA', example) && strcmp('CD', labelType)
            indexZeros = find(all(labelChoose == 0, 2));
            labelChoose(indexZeros, :) = [];
            features(indexZeros, :) = [];
            dataEvent(indexZeros, :) = [];
        else
        end

        %% Learning with Random Forest
        [predictLabel, testLabel, testFeatures] = random_forest(features, labelChoose, percentageTrainingData);
        
        %% Validation for Random Forest
        accuracy = [];
        for i = 1:size(labelChoose, 2)
            accuracy = [accuracy, sum(predictLabel(:, i) == categorical(testLabel(:, i))) / numel(testLabel(:, i))];
        end
        disp(['Accuracy: ', num2str(accuracy)]);
    else
    end

elseif strcmp('Event+2', labelType) || strcmp('Event+1', labelType)
    %% Label n+1 for event prediction
    [labelEventPrediction, dataEventPrediction, nextEvent] = label_event_prediction(dataEvent, event);
    if strcmp('LSTM', MLType)
        numClasses = length(event); % Number of output classes for the LSTM
        labelEventPrediction = nextEvent;
        %% Data for LSTM
        [xRNN, yRNN] = data_for_RNN(dataEventPrediction, event, labelEventPrediction);
        
        %% Learning for LSTM
        [predictLabel, testLabel, layers, net, options] = recurrent_neural_network(xRNN, yRNN, percentageTrainingData, event, numClasses);
        
        %% Validation for LSTM
        accuracy = sum(predictLabel{1} == categorical(testLabel{1})) / numel(testLabel{1});
        disp(['Accuracy: ', num2str(accuracy)]);
    elseif strcmp('LR', MLType)
        %% Data for Logistic regression
        [features] = data_for_LR(dataEventPrediction, dataTransitions);
        
        %% Learning with Logistic Regression
        nbIteration = 100;
        accuracy = [];
        bestAccuracy = 0;

        for i = 1:nbIteration
            [predictions, testLabel, ~, theta] = logistic_regression(features, labelEventPrediction, percentageTrainingData);
        
        %% Validation for Logistic Regression
            % Decision threshold
            threshold = 1/length(event);
        
            % Classification layer
            predictLabel = zeros(size(predictions));
            for j = 1:size(predictions, 1)
                if max(predictions(j, :)) >= threshold
                    [~, indexMaxPredictions] = max(predictions(j, :));
                    predictLabel(j, indexMaxPredictions) = 1;
                else
                end
            end
    
            predictFeatures = predictLabel .* event;
            testFeatures = testLabel .* event;
            realPredictLabel = [];
            realTestLabel = [];
            for j = 1:size(predictLabel, 1)
                realPredictLabel = [realPredictLabel; max(predictFeatures(j, :))];
                realTestLabel = [realTestLabel; max(testFeatures(j, :))]; 
            end
            accuracy = [accuracy; mean(realTestLabel == realPredictLabel)];

            % Save the best predictions
            if bestAccuracy < accuracy(i)
                bestAccuracy = accuracy(i);
                bestNetwork = theta;
                indexBestPredictions = i;
            else
            end
        end
        
        disp('Mean of the accuracy:');
        meanAccuracy = mean(accuracy);
        disp(meanAccuracy);
        
        disp('Worst accuracy:');
        minAccuracy = min(accuracy);
        disp(minAccuracy);
        
        disp('Best accuracy:');
        maxAccuracy = max(accuracy);
        disp(maxAccuracy);
        
        disp('Range of the accuracy:')
        rangeAccuracy = range(accuracy);
        disp(rangeAccuracy);
    elseif strcmp('RF', MLType)
        %% Data for Random Forest
        [features] = data_for_LR(dataEventPrediction, dataTransitions);
        labelChoose = nextEvent;

        %% Learning with Random Forest
        [predictLabel, testLabel, testFeatures] = random_forest(features, labelChoose, percentageTrainingData);
        
        %% Validation for Random Forest
        accuracy = [];
        for i = 1:size(labelChoose, 2)
            accuracy = [accuracy, sum(predictLabel(:, i) == categorical(testLabel(:, i))) / numel(testLabel(:, i))];
        end
        disp(['Accuracy: ', num2str(accuracy)]);
    else
    end

else
end
