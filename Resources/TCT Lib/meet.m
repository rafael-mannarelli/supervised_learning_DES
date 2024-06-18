% name3 = meet(name1,name2,...)
function meet(varargin)
global path;
global prm_file; 
global rst_file;
global tct_name;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 4;
err_info(1) = code;

% check if the input DES exist
for i = 2:nargin
    full_name = strcat(path, '\');
    full_name = strcat(full_name, varargin{i});
    full_name = strcat(full_name, '.DES');

    if ~exist(full_name, 'file')
        err_info(2) = 7;
        printerror(varargin{i});
        return;
    end
end

%--------------------------------------------------------------------------
% generate the prm file for meet
fid = fopen(prm_file, 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror(prm_file);
    return;
end

fprintf(fid, '0\n'); % debug_mode
fprintf(fid, '1\n'); % min_flag
fprintf(fid, '%d\n', code); % code for meetk
fprintf(fid, '%s\n', varargin{1}); % name of producted DES
fprintf(fid, '%d\n', nargin - 1); % number of DES to be composed 
for i = 2:nargin
    fprintf(fid, '%s\n', varargin{i});
end

fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure meet
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
elseif result ~= 0
    err_info(2) = 6;
    printerror;
    return
end

% check if the file to be created exists
full_name = strcat(path, '\');
full_name = strcat(full_name, varargin{1});
full_name = strcat(full_name, '.DES');

if ~exist(full_name, 'file')
    err_info(2) = 4;
    printerror(varargin{1});
    return;
end

printerror;

[state_size, tran_size] = getdes_parameter(varargin{1});

%--------------------------------------------------------------------------
% write the result into makeit file
fid = fopen('tmp.$$$', 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror('tmp.$$$');
    return;
end
fprintf(fid, '%s = Meet(',varargin{1});
for i = 2:nargin
    fprintf(fid, '%s', varargin{i});
    if i < nargin
        fprintf(fid, ',');
    end
end
fprintf(fid, ')  (%d,%d)\n\n', state_size, tran_size);
fclose(fid);

mergechop(length(varargin{1}) + 3);

%--------------------------------------------------------------------------
%remove the temporary files
fclose('all'); % close all open files
if exist(prm_file, 'file')
    delete(prm_file);
end
if exist(rst_file, 'file')
    delete(rst_file);
end

end %function
% the end -----------------------------------------------------------------