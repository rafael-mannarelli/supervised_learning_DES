function [predictLabel, testLabel, layers, net, options] = recurrent_neural_network(xRNN, yRNN, percentageTrainingData, event, numClasses)

    % This function trains an LSTM-based recurrent neural network on provided
    % sequence data and evaluates it on a test set.

    % Inputs:
    % xRNN - A cell array where each cell contains a sequence of input data
    % yRNN - A matrix of labels corresponding to each sequence in xRNN
    % percentageTrainingData - The proportion of data to be used for training
    % event - A vector containing all the possible events
    % numClasses - The number of output classes for classification

    % Outputs:
    % predictLabel - Predicted labels for the test set
    % testLabel - Actual labels for the test set
    % layers - The architecture of the LSTM network
    % net - The trained LSTM network
    % options - The training options used for the LSTM network

    % The LSTM network is trained to classify sequences into one of the specified
    % number of classes. This function is useful for sequence classification tasks
    % in various applications, including time-series analysis and natural language processing.

for i = 1:size(yRNN, 2)
    % Data
    sequences = xRNN;
    labels = yRNN(:, i);

    % Splitting data into training and testing sets
    nbSequences = size(sequences, 1);
    index = randperm(nbSequences);
    trainRatio = percentageTrainingData; % Training ratio (80%)
    trainIndex = index(1:round(trainRatio * nbSequences));
    testIndex = index(round(trainRatio * nbSequences) + 1:end);

    trainSequences = sequences(trainIndex, :);
    trainLabels = labels(trainIndex, :);

    testSequences = sequences(testIndex, :);
    testLabels = labels(testIndex, :);

    % Creating the LSTM model
    inputSize = length(event); % Input size for each time step
    numHiddenUnits = 640; % Number of LSTM hidden units
    maxEpochs = 100; % Maximum number of epochs for training
    miniBatchSize = 64; % Mini-batch size for weight updates
    learningRate = 0.001; % Learning rate of the training
    regularizationL2 = 0.0005; % Coefficient of the L2 Regularization

    layers = [ ...
        sequenceInputLayer(inputSize) % Input layer
        bilstmLayer(numHiddenUnits, 'OutputMode', 'last') % Bidirectional LSTM layer
        % dropoutLayer % Dropout layer (commented out)
        fullyConnectedLayer(numClasses) % Fully connected layer
        softmaxLayer % Softmax layer
        classificationLayer]; % Classification layer

    % Setting training options
    options = trainingOptions('adam', ...
        'MaxEpochs', maxEpochs, ...
        'MiniBatchSize', miniBatchSize, ...
        'Shuffle', 'every-epoch', ...
        'ValidationData', {testSequences, categorical(testLabels)}, ...
        'InitialLearnRate', learningRate, ...
        'LearnRateSchedule', 'none', ...
        'L2Regularization', regularizationL2, ...
        'Plots', 'training-progress', ...
        'ExecutionEnvironment', 'parallel', ...
        'OutputNetwork', 'best-validation-loss');

    disp(['Number of training sequences: ' num2str(size(trainSequences, 1))]);
    disp(['Number of training labels: ' num2str(size(trainLabels, 1))]);

    % Training the model
    net = trainNetwork(trainSequences, categorical(trainLabels), layers, options);

    % Prediction on the test set
    predictedLabels = classify(net, testSequences);
    testLabel(:, i) = {testLabels};
    predictLabel(:, i) = {predictedLabels};
end
