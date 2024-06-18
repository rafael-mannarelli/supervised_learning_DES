% displaytxt(filename)
function displaytxt(name1)
global path;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 35;
err_info(1) = code;

% check if the input DES exist
full_name = strcat(path, '\');
full_name = strcat(full_name, name1);
full_name = strcat(full_name, '.TXT');

if ~exist(full_name, 'file')
    err_info(2) = 7;
    printerror(name1);
    return;
end

%--------------------------------------------------------------------------
% get and display the txt file
fid = fopen(full_name, 'r');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror(full_name);
    return;
end

A = fscanf(fid, '%s\r')

fclose(fid);
%--------------------------------------------------------------------------

printerror;


end %function
% the end -----------------------------------------------------------------