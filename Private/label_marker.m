function [labelMarker]=label_marker(dataMarker,dataEndPos)

    % This function labels the end positions of sequences in a DES
    % to indicate whether they correspond to marker states.

    % Inputs:
    % dataMarker - A vector containing the marker states in the DES
    % dataEndPos - A vector containing the end positions of sequences

    % Output:
    % labelMarker - A logical vector where each element indicates whether
    %               the corresponding end position in dataEndPos is a marker state

labelMarker=ismember(dataEndPos,dataMarker);