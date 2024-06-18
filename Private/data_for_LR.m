function [features]=data_for_LR(dataEvent,dataTransitions)

    % This function processes event data for use in Logistic Regression within
    % the context of Discrete-Event Systems. It counts the occurrences of
    % each event in the sequences to create a feature matrix.

    % Inputs:
    % dataEvent - A matrix where each row represents an event sequence
    % dataTransitions - A matrix representing possible state transitions

    % Output:
    % features - A matrix where each row corresponds to a sequence in dataEvent
    %            and each column corresponds to a specific event. The elements
    %            are counts of how often each event occurs in each sequence.

features=[];

for i=1:max(dataTransitions(:,2)) 
    checkEvent=dataTransitions(:,2)==i;
    if sum(checkEvent)>0
        features=[features,sum(dataEvent==i,2)];
    end
end