% name1 = printdat(name2)
function printdat(varargin)
global path;
global prm_file; 
global rst_file;
global tct_name;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 34;
err_info(1) = code;
if nargin == 1
    name1 = varargin{1};
    name2 = varargin{1};
elseif nargin == 2
    name2 = varargin{1};
    name1 = varargin{2};
end

% check if the input DES exist
full_name = strcat(path, '\');
full_name = strcat(full_name, name1);
full_name = strcat(full_name, '.DAT');

if ~exist(full_name, 'file')
    err_info(2) = 8;
    printerror(name1);
    return;
end

%--------------------------------------------------------------------------
% generate the prm file for printdat
fid = fopen(prm_file, 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror(prm_file);
    return;
end

fprintf(fid, '0\n'); % debug_mode
fprintf(fid, '1\n'); % min_flag
fprintf(fid, '34\n'); % code for printdat
fprintf(fid, '%s\n', name1); % name of DAT to be printed
fprintf(fid, '%s\n', name2); % name of target txt file

fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure dispdes
cmdline = strcat(tct_name, ' -cmdline');
if system(cmdline) ~= 0
    err_info(2) = 2;
    printerror;
    return;
end

% get the result of executing TCT procedure
if exist(rst_file, 'file')
    fid = fopen(rst_file, 'r');
    if fid == -1
        err_info(2) = 1;
        printerror(rst_file);
        return;
    end
    if feof(fid)
        err_info(2) = 5;
        printerror;
        fclose(fid);
        return;
    end
    result = fscanf(fid, '%d',1);
    fclose(fid);
else
    err_info(2) = 5; % no result file generated; fail to do this operation
    printerror;
    return;
end

if result == 3
    err_info(2) = 3;
    printerror;
    return;
elseif result == -2
    err_info(2) = 4;
    printerror(name2);
    return;
elseif result ~= 0
    err_info(2) = 6;
    printerror;    
    return;
end

% check if the file to be created exists
full_name = strcat(path, '\');
full_name = strcat(full_name, name2);
full_name = strcat(full_name, '.TXT');

if ~exist(full_name, 'file')
    err_info(2) = 4;
    tmpname = strcat(name2, '.TXT');
    printerror(tmpname);
    return;
end

%--------------------------------------------------------------------------
%remove the temporary files
fclose('all'); % close all open files
if exist(prm_file, 'file')
    delete(prm_file);
end
if exist(rst_file, 'file')
    delete(rst_file);
end

printerror;

end %function
% the end -----------------------------------------------------------------