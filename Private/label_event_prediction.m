function [labelEventPrediction,dataEventPrediction,nextEvent]=label_event_prediction(dataEvent,event)

    % This function prepares data for event prediction by processing sequences
    % of events and creating labels that indicate the next event in each sequence.

    % Inputs:
    % dataEvent - A matrix where each row represents a sequence of events
    % event - A vector containing all possible events

    % Outputs:
    % labelEventPrediction - A binary matrix indicating the next event in each sequence
    % dataEventPrediction - A matrix of event sequences modified for prediction
    % nextEvent - A vector indicating the next event for each sequence

randomIndex=[];
randomValue=[];
dataEventPrediction=[];
nextEvent=[];
for i=1:size(dataEvent,1)
    indexSup0(i,:)={find(dataEvent(i,:) > 0)};
    if ~isempty(indexSup0{i,:})
        chooseIndex=indexSup0{i,:};
        if length(chooseIndex)==1
            randomIndex = [randomIndex;chooseIndex(randi(length(indexSup0{i,:})))];
        else
            randomIndex = [randomIndex;chooseIndex(randi(length(indexSup0{i,:})-1))];
        end
        randomValue = [randomValue;dataEvent(i,randomIndex(end))];
        dataEventPrediction=[dataEventPrediction;dataEvent(i,1:randomIndex(end)),zeros(1,size(dataEvent,2)-randomIndex(end))];
        nextEvent=[nextEvent;dataEvent(i,randomIndex(end)+1)];
    else
    end
end
stopSequence=find(nextEvent==0);
nextEvent(stopSequence)=[];
dataEventPrediction(stopSequence,:)=[];

sizeEvent=size(event,2);
sizeData=size(nextEvent,1);
labelEventPrediction=zeros(sizeData,sizeEvent);
for i=1:sizeData
    for j=1:sizeEvent
            if nextEvent(i)==event(j)
                labelEventPrediction(i,j)=1;
            end
    end
end
labelEventPrediction=logical(labelEventPrediction);