function [xRNN,yRNN,event]=data_for_RNN(dataEvent,event,label)

    % This function prepares data from event sequences for training RNNs.
    % It creates a binary representation for each event in the sequences
    % and associates these with corresponding labels.

    % Inputs:
    % dataEvent - A matrix where each row represents an event sequence
    % event - A vector containing all the possible events
    % label - A vector or matrix containing labels for each sequence in dataEvent

    % Outputs:
    % xRNN - A cell array where each cell contains a binary representation of
    %        an event sequence
    % yRNN - The labels associated with each sequence, formatted for RNN training

xRNN=cell(size(dataEvent,1),1);
%yRNN=categorical(label);
yRNN=label;
for i=1:size(dataEvent,1)
    for j=1:size(dataEvent,2)
        temp=[];
        for k=1:size(event,2)
            if dataEvent(i,j)==event(1,k)
                temp=cat(1, temp, 1);
            else
                temp=cat(1, temp, 0);
            end
        end
        xRNN{i} = cat(2, xRNN{i}, temp);
    end
end

event=unique(dataEvent(dataEvent>0));

