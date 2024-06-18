% loc = localize(plant,sup,component)
function localize(loc,plant,sup,component)
global path;
global prm_file; 
global rst_file;
global tct_name;
global err_info;

if err_info(2) ~= 0
    return;
end

code = 11;
err_info(1) = code;

num_component = length(component); % get the number of plant components
num_loc = length(loc);  % get the number of local controllers to be constructed

% check if the input DES plant exists
full_name = strcat(path, '\');
full_name = strcat(full_name, plant);
full_name = strcat(full_name, '.DES');

if ~exist(full_name, 'file')
    err_info(2) = 7;
    printerror(plant);
    return;
end

% check if the input DES sup exists
full_name = strcat(path, '\');
full_name = strcat(full_name, sup);
full_name = strcat(full_name, '.DES');

if ~exist(full_name, 'file')
    err_info(2) = 7;
    printerror(sup);
    return;
end

% check if the input plant components exist
for i = 1: num_component
    full_name = strcat(path, '\');
    full_name = strcat(full_name, component{i});
    full_name = strcat(full_name, '.DES');

    if ~exist(full_name, 'file')
        err_info(2) = 7;
        printerror(component{i});
        return;
    end
end

%--------------------------------------------------------------------------
% generate the prm file for localize
fid = fopen(prm_file, 'w');
if fid == -1 % cannot open the specified file
    err_info(2) = 1; 
    printerror(prm_file);
    return;
end

fprintf(fid, '0\n'); % debug_mode
fprintf(fid, '1\n'); % min_flag
fprintf(fid, '%d\n', code); % code for localize
fprintf(fid, '%s\n', plant);
fprintf(fid, '%s\n', sup);
fprintf(fid, '%d\n', num_component);
for i = 1: num_component
    fprintf(fid, '%s\n', component{i});
end
fprintf(fid, '%d\n', num_loc);
for i = 1: num_loc
    fprintf(fid, '%s\n', loc{i});
end
fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure localize
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

% check if the files to be computed exist
for i = 1: num_loc
    full_name = strcat(path, '\');
    full_name = strcat(full_name, loc{i});
    full_name = strcat(full_name, '.DES');

    if ~exist(full_name, 'file')
        err_info(2) = 4;
        printerror(loc{i});
        return;
    end
end

printerror;

des_size = zeros(num_loc,2);
for i = 1: num_loc    
    [des_size(i,1), des_size(i,2)] = getdes_parameter(loc{i});
end

%--------------------------------------------------------------------------
% write the result into makeit file
for i = 1: num_loc
    fid = fopen('tmp.$$$', 'w');
    if fid == -1 % cannot open the specified file
        err_info(2) = 1;
        printerror('tmp.$$$');
        return;
    end    
    fprintf(fid, '%s = Localize(%s,%s,%s)',loc{i}, plant, sup, component{i});   
    fprintf(fid, '  (%d,%d)\n\n', des_size(i,1), des_size(i,2));
    fclose(fid);
    mergechop(length(loc(i)) + 3);
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

end %function
% the end -----------------------------------------------------------------