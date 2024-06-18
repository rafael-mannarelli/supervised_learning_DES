function []=parser_dat(file,fileName,path)

    % This function reads control data from a text file, processes it, and
    % saves the processed data to a new file.
    % Inputs:
    % file - The path to the input text file containing the control data
    % fileName - The name of the output file (without extension)
    % path - The directory path where the output file will be saved

    % Outputs:
    % outputfile - the output text file generated

% Read the text file
data = fopen(file, 'r');
textData = textscan(data, '%s', 'Delimiter', '\n');
fclose(data);

% Find the index from which the control data starts
startIndex = find(strcmp(textData{1}, 'control data:')) + 1;

% Extract control data
controlData = textData{1}(startIndex:end);

controlData = controlData(~cellfun('isempty', controlData));

nbSpace = 10;
newControlData={};

for i=1:length(controlData)
    line = controlData{i};
    data={strsplit(line, repmat(' ', 1, nbSpace))};
    newControlData = vertcat(newControlData,data);
end
if mod(length(newControlData),2)==0
    newControlData1=vertcat(newControlData{:});
        newControlData3={};
    for i = 1:length(newControlData1)
        newControlData2=vertcat(vertcat(newControlData1(i,1), newControlData1(i,2)));
        newControlData3=vertcat(newControlData3,newControlData2);
    end
    controlData=newControlData3;
else
        newControlData1=vertcat(newControlData{1:end-1});
        newControlData3={};
    for i = 1:length(newControlData1)
        newControlData2=vertcat(vertcat(newControlData1(i,1), newControlData1(i,2)));
        newControlData3=vertcat(newControlData3,newControlData2);
    end
controlData=vertcat(newControlData3,newControlData(end));
end

controlData = cellfun(@strtrim, controlData, 'UniformOutput', false);

for i = 1:length(controlData)
    str=controlData{i};
    str = strrep(str, ':', '');
    str = regexprep(str, '\s+', ' ');
    str = strrep(str, ' ', ',');
    str = strcat(str, ',');
    controlData{i}=str;
end

% Save control data to a new file
outputFile = fopen([path,fileName,'_control_data.txt'], 'w');

% Loop through cell elements and write them to file
for i = 1:length(controlData)
    fprintf(outputFile, '%s\n',string(controlData{i}));
end

% Close file
fclose(outputFile);

