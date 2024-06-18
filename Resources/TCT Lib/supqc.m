% name2 = sup(s)qc(name1, null_list)
function supqc(name2, name1, mode, null_list)
global path;
global tct_name;
global prm_file; 
global rst_file;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 23;
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

flag = 1;

if strcmp(mode, 'qc') == 1
    flag = 1;
elseif strcmp(mode, 'sqc') == 1
    flag = 2;
end

%--------------------------------------------------------------------------
% generate the prm file for supqc
fid = fopen(prm_file, 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror(prm_file);
    return;
end

fprintf(fid, '0\n'); % debug_mode
fprintf(fid, '1\n'); % min_flag
fprintf(fid, '%d\n', code); % code for sup(s)qc
fprintf(fid, '%d\n', flag); % mode for supqc or supsqc
fprintf(fid, '%s\n', name1);
fprintf(fid, '%s\n', name2); 
for i = 1: length(null_list)
    fprintf(fid, '%d\n', null_list(i));
end

fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure supqc or sqc
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

% check if the file to be computed exists
full_name = strcat(path, '\');
full_name = strcat(full_name, name2);
full_name = strcat(full_name, '.DES');

if ~exist(full_name, 'file')
    err_info(2) = 4;
    printerror(name2);
    return;
end

printerror;

[state_size, tran_size, is_det] = getdes_parameter(name2);

%--------------------------------------------------------------------------
% write the result into makeit file
fid = fopen('tmp.$$$', 'w');
if fid == -1 % cannot open the specified file
    err_info = 1; 
    printerror('tmp.$$$');
    return;
end
if flag == 1
    fprintf(fid, '%s = Supqc(%s,Null[', name2, name1);
elseif flag == 2
    fprintf(fid, '%s = Supsqc(%s,Null[', name2, name1);
end
for i = 1:length(null_list)
    fprintf(fid, '%d', null_list(i));
    if i < length(null_list)
        fprintf(fid, ',');
    end
end
fprintf(fid, '],');
if flag == 1
    fprintf(fid, 'QC[state partition omited]');
elseif flag == 2
    fprintf(fid, 'SQC[state partition omited]');
end
fprintf(fid, ')  (%d,%d)', state_size, tran_size);
if is_det == 1
    fprintf(fid, '  Deterministic');
else
    fprintf(fid, '  Nondeterministic');
end
fprintf(fid, '\n\n');
fclose(fid);

mergechop(length(name2) + 3);

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