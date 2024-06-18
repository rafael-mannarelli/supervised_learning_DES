function [dataEvent,posList,dataEndPos]=sup_to_data(dataTransitions,dataMarker,mean,sigma,maxU,minU,randomType,sizeSampling)
    
    % This function generates simulation data for supervisory control in DES.
    % It simulates the transitions of a system based on specified parameters and
    % creates sequences of events that represent system behavior.

    % Inputs:
    % dataTransitions - Matrix representing possible state transitions
    % dataMarker - Vector of marker states
    % mean, sigma - Parameters for Gaussian distribution (used if randomType is 'Gaussian')
    % maxU, minU - Upper and lower bounds for uniform distribution (used if randomType is 'Uniform')
    % randomType - Type of random number generation ('Gaussian' or 'Uniform')
    % sizeSampling - Number of samples (sequences) to generate

    % Outputs:
    % dataEvent - Matrix where each row represents an event sequence
    % posList - Struct that records the states visited in each sample
    % dataEndPos - Vector storing the final state in each sequence

posList=struct;
posList.controlData=[];

if strcmp('Gaussian',randomType)
    lenControlData = mean + sigma*4; 
else
    lenControlData=maxU;
end

dataEvent = zeros([sizeSampling,lenControlData]); 
nList=[];
w=0;

for m=1:sizeSampling
    if strcmp('Gaussian',randomType)
        n = 0; 
        while n <= 0 || n >= lenControlData
            r = normrnd(mean,sigma);  
            n = round(r, 0); 
        end
    else
        r = (maxU - minU).*rand(1) + minU;
        n = round(r, 0);
    end
    nList=[nList;n];
    pos=dataTransitions(1,1); 
    posList(m+w).controlData=pos;
    sizeDataTransitions=length(dataTransitions);
    
    for k=1:n
        event=zeros(sizeDataTransitions,1);
        for i=1:sizeDataTransitions
            if pos == dataTransitions(i,1)
                event(i,1)=dataTransitions(i,2);
            end
        end
        indexEvent=find(event>0);

        if ~isempty(indexEvent)
            indexRand=randsample(length(indexEvent),1);
            nextPos=dataTransitions(indexEvent(indexRand,1),3);
            pos=nextPos;
            posList(m+w).controlData=cat(1,posList(m+w).controlData,pos);
            dataEvent(m+w,k)=dataTransitions(indexEvent(indexRand,1),2);
        else
        end
    end
    posMarker=ismember(posList(m+w).controlData, dataMarker);
    if find(posMarker>0)
        indexMarker=find(posMarker==1); 
        indexLastMarker=max(indexMarker);
        if posList(m+w).controlData(end)~=posList(m+w).controlData(indexLastMarker)
            w=w+1;
            posList(m+w).controlData=posList(m+w-1).controlData(1:indexLastMarker);
            dataEvent(m+w,:)=[dataEvent(m+w-1,1:indexLastMarker-1),zeros(1,lenControlData-indexLastMarker+1)];
        else
        end
    end
end

for i=1:length(posList)
    dataEndPos(i)=posList(i).controlData(end);
end
dataEndPos=transpose(dataEndPos);