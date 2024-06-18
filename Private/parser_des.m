function []=parser_des(file,fileName,path)

    % This function reads DES data from a text file, processes it, and
    % saves the processed data to a new file. 

    % Inputs:
    % file - The path to the input text file containing the DES data
    % fileName - The name of the output file (without extension)
    % path - The directory path where the output file will be saved

    % Outputs:
    % markerStatesFile - the output text file generated containing the marker states informations
    % transitionsFile- the output text file generated containing the transitions informations



data = fopen(file, 'r');  % Open the SUP.txt file
transitions = [];  % Stock the event
markerStates = [];  % Stock the marker states

line = fgets(data);
while ischar(line)
    if contains(line, 'transitions:')
        line = fgets(data);
        while ischar(line) && ~contains(line, 'marker states:')
            transitions = [transitions, str2num(line)]; 
            line = fgets(data);
        end
    elseif contains(line, 'marker states:')
        line = fgets(data);
        while ischar(line) && ~contains(line, 'vocal states:')
            if ~isempty(strtrim(line))
                markerStates = [markerStates, str2num(line)];  
            end
            line = fgets(data);
        end
    else
        line = fgets(data);
    end
end

fclose(data);  
transitions=reshape(transitions,3,[]); 

% Write events to a new .txt file
transitionsFile = fopen([path,fileName,'_transitions.txt'], 'w');
for i = 1:size(transitions, 2)
    fprintf(transitionsFile, '%d, %d, %d\n', transitions(1, i), transitions(2, i), transitions(3, i));
end
fclose(transitionsFile);

% Write marker states to a new .txt file
markerStatesFile = fopen([path,fileName,'_marker_states.txt'], 'w');
for i = 1:size(markerStates, 2)
    fprintf(markerStatesFile, '%d\n', markerStates(i));
end
fclose(markerStatesFile);