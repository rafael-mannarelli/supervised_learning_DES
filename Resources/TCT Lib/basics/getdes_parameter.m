% getdes_parameter(name1)
function [state_size, tran_size, is_det, is_controllable] = getdes_parameter(varargin)
global path;
global tct_name;
global prm_file; 
global rst_file;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 31;
err_info(1) = code;

name1 = varargin{1}; 

if nargin == 1
   format = 0;
else
    format = varargin{2};
end

% check if the input DES exists
full_name = strcat(path, '\');
full_name = strcat(full_name, name1);
if format == 0
    full_name = strcat(full_name, '.DES');
else
    full_name = strcat(full_name, '.DAT');
end

if ~exist(full_name, 'file')
    err_info(2) = 7;
    printerror(name1);
    return;
end

%--------------------------------------------------------------------------
% generate the prm file for trim
fid = fopen(prm_file, 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror(prm_file);
    return;
end

fprintf(fid, '0\n'); % debug_mode
fprintf(fid, '1\n'); % min_flag
fprintf(fid, '%d\n', code); % code for getdes_parameter
fprintf(fid, '%s\n', name1); 
fprintf(fid, '%d\n', format); 

fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure getdes_parameter
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
    state_size = fscanf(fid, '%d',1);
    tran_size = fscanf(fid, '%d', 1);
    is_det = fscanf(fid, '%d',1);
    is_controllable = fscanf(fid, '%d',1);
    
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

%--------------------------------------------------------------------------
%remove the temporary files
fclose('all'); % close all open files
if exist(prm_file, 'file')
    delete(prm_file);
end
if exist(rst_file, 'file')
    delete(rst_file);
end

%printerror;

end %function
% the end -----------------------------------------------------------------