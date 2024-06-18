% name2 = complement(name1)
function complement(name2, name1, aux_list)
global path;
global tct_name;
global prm_file; 
global rst_file;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 10;

err_info(1) = code;

% check if the input des exists
full_name = strcat(path, '\');
full_name = strcat(full_name, name1);
full_name = strcat(full_name, '.DES');

if ~exist(full_name, 'file')
    err_info(2) = 7;
    printerror(name1);
    return;
end


%--------------------------------------------------------------------------
% generate the prm file for complement
fid = fopen(prm_file, 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1;
    printerror(prm_file);
    return;
end

fprintf(fid, '0\n'); % debug_mode
fprintf(fid, '1\n'); % min_flag
fprintf(fid, '%d\n', code); % code for complement
fprintf(fid, '%s\n', name1); 
fprintf(fid, '%s\n', name2);
for i = 1: length(aux_list)
    fprintf(fid, '%d\n', aux_list(i));
end

fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure minstate
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

[state_size, tran_size] = getdes_parameter(name2);

%--------------------------------------------------------------------------
% write the result into makeit file
fid = fopen('tmp.$$$', 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror('tmp.$$$');
    return;
end
fprintf(fid, '%s = Complement(%s,[', name2, name1);
for i = 1:length(aux_list)
    fprintf(fid, '%d', aux_list(i));
    if i < length(aux_list)
        fprintf(fid, ',');
    end
end
fprintf(fid, '])  (%d,%d)\n\n', state_size, tran_size);
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