% is_observable = (s)observable(name1,name2, null_list)
function is_observable = observable(name1, name2, mode, null_list)
global path;
global tct_name;
global prm_file; 
global rst_file;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 26;
err_info(1) = code;

% check if the input DES exists
full_name = strcat(path, '\');
full_name = strcat(full_name, name1);
full_name = strcat(full_name, '.DES');

if ~exist(full_name, 'file')
    err_info(2) = 7;
    printerror(name1);
    return;
end

% check if the input DES exists
full_name = strcat(path, '\');
full_name = strcat(full_name, name2);
full_name = strcat(full_name, '.DES');

if ~exist(full_name, 'file')
    err_info(2) = 7;
    printerror(name2);
    return;
end

flag = 1;

if strcmp(mode, 'o') == 1
    flag = 1;
elseif strcmp(mode, 'so') == 1
    flag = 2;
end

%--------------------------------------------------------------------------
% generate the prm file for observable
fid = fopen(prm_file, 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror(prm_file);
    return;
end

fprintf(fid, '0\n'); % debug_mode
fprintf(fid, '1\n'); % min_flag
fprintf(fid, '%d\n', code); % code for (s)observable
fprintf(fid, '%d\n', flag); % mode for observable or strong observable
fprintf(fid, '%s\n', name1);
fprintf(fid, '%s\n', name2); 
for i = 1: length(null_list)
    fprintf(fid, '%d\n', null_list(i));
end

fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure observable or strong observable
cmdline = strcat(tct_name, ' -cmdline');
if system(cmdline) ~= 0
    err_info(2) = 2;
    printerror;
    return;
end

% get the result of executing TCT procedure
is_observable = 0;
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
    
    if feof(fid)
        err_info(2) = 5;
        printerror;
        fclose(fid);
        return;
    end
    is_observable = fscanf(fid, '%d',1);    
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
% write the result into makeit file
fid = fopen('tmp.$$$', 'w');
if fid == -1 % cannot open the specified file
    err_info = 1; 
    printerror('tmp.$$$');
    return;
end
if is_observable ==1 
    fprintf(fid, 'true');
    offset = 7;
else
    fprintf(fid, 'false');
    offset = 8;
end

if flag == 1
    fprintf(fid, ' = Obs(%s,%s,Null[', name1, name2);
elseif flag == 2
    fprintf(fid, ' = Sobs(%s,%s,Null[', name1, name2);
end
for i = 1:length(null_list)
    fprintf(fid, '%d', null_list(i));
    if i < length(null_list)
        fprintf(fid, ',');
    end
end
fprintf(fid, '])\n\n');
fclose(fid);

mergechop(offset);

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