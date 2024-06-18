% function to create a DES
function create(name,Q,Tran,Qm)
global path;
global prm_file; 
global rst_file;
global tct_name;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 0;
err_info(1) = code;
%--------------------------------------------------------------------------
% generate the prm file for create DES
fid = fopen(prm_file, 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1;
    printerror(prm_file);
    return;
end

fprintf(fid, '0\n'); % debug_mode
fprintf(fid, '1\n'); % min_flag
fprintf(fid, '%d\n', code); % code for create
fprintf(fid, '%s\n', name); % name of DES to create
fprintf(fid, '%d\n', Q); % state number of DES

 % write marker states
m = length(Qm);
for i = 1: m
    fprintf(fid, '%d ', Qm(i)); 
end
fprintf(fid, '-1\n');

% write  transitions
[m,n]=size(Tran);
for i = 1:m
    for j = 1:n
        fprintf(fid, '%d ', Tran(i,j));  
    end
    fprintf(fid, '\n');
end
fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure create
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
full_name = strcat(full_name, name);
full_name = strcat(full_name, '.DES');

if ~exist(full_name, 'file')
    err_info(2) = 4;
    printerror(name);
    return;
end

printerror;

[state_size, tran_size] = getdes_parameter(name);

%--------------------------------------------------------------------------
% write the result into makeit file
fid = fopen('tmp.$$$', 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror('tmp.$$$');
    return;
end
fprintf(fid, '%s = Create(%s',name, name);
m = length(Qm);
if m > 0 
    fprintf(fid, ',[mark ');
    for i = 1: m
        fprintf(fid, '%d', Qm(i));
        if i < m
            fprintf(fid, ',');
        end
    end
    fprintf(fid, ']');
end
[m,n]=size(Tran);
if m > 0
    fprintf(fid, ',[Tran ');
    for i = 1:m
        fprintf(fid, '[');
        for j = 1:n
            fprintf(fid, '%d', Tran(i,j));
            if j < n
                fprintf(fid, ',');
            end
        end
        fprintf(fid, ']');
    end
    fprintf(fid, ']');
end
fprintf(fid, ')  (%d,%d)\n\n', state_size, tran_size);
fclose(fid);

mergechop(length(name) + 3);

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