function [labelControlData, controlEvent, controlList] = label_control_data(dataControlData, dataEndPos)

    % This function processes control data to create labels for each sequence
    % in a DES, based on the controllable events and the end positions of the sequences.

    % Inputs:
    % dataControlData - Matrix containing control data sequences
    % dataEndPos - Vector containing the end positions of each sequences

    % Outputs:
    % labelControlData - Binary matrix indicating the presence of control events in each sequence
    % controlEvent - Vector of unique control events extracted from dataControlData
    % controlList - Modified list of control data sequences

controlList = [];
sizeDataPos = size(dataEndPos, 1);
sizeControlData = size(dataControlData, 1);

for i = 1:sizeDataPos
    flag = 0;
    for m = 1:sizeControlData
        if dataEndPos(i) == dataControlData(m, 1)
            controlList = [controlList; dataControlData(m, :)];
            flag = 1;
        end
    end
    if flag == 0
        controlList = [controlList; [dataEndPos(i), zeros(1, size(dataControlData, 2) - 1)]];
    end
end

lengthContList = length(controlList);
widthContList = width(controlList);

controlEvent = unique(dataControlData(:, 2:end));
supNaN = isnan(controlEvent);
controlEvent = controlEvent(~supNaN);
numberControlEvent = length(controlEvent);

labelControlData = zeros(lengthContList, numberControlEvent);

for i = 1:lengthContList
    for k = 1:numberControlEvent
        for j = 2:widthContList
            if controlList(i, j) == controlEvent(k)
                labelControlData(i, k) = 1;
            end
        end
    end
end

labelControlData = logical(labelControlData);

% Uncomment the following code if you want to retain non-zero elements in each row as cell arrays
% labelRNN = labelControlData .* transpose(controlEvent);
% 
% % Cell array for storing rows without zeros
% cellLabel = cell(size(labelRNN, 1), 1);
% 
% % Iterate through each row of the matrix
% for i = 1:size(labelRNN, 1)
%     % Remove zeros from the row
%     supZeros = labelRNN(i, labelRNN(i, :) ~= 0);
% 
%     % Store the row in the cell array
%     cellLabel{i} = supZeros;
% end
% 
% labelRNN = cellLabel;
