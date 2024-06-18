% loc = localize(plant,sup,component)
function exlocalize(loc,plant,sup,mode,is_single)
global path;
global prm_file; 
global rst_file;
global tct_name;
global err_info;
global timer;

if err_info(2) ~= 0
    return;
end

code = 35;
err_info(1) = code;

if(is_single == 1)    
    num_loc = size(loc,1);  % get the number of local controllers to be constructed
    eventlist = zeros(num_loc,1);
    %loc_name(num_loc,1) = ' ';
    for i = 1: num_loc
        str = upper(char(loc(i,1)));
        if strcmp(str, 'MARK')
            eventlist(i) = 1001;
        else
            eventlist(i) = str2num(str);
        end
    end
else
    num_loc = 1;
    eventlist = cell2mat(loc{1,1});
end

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
fprintf(fid, '%d\n', mode); % run old or new localization procedure
fprintf(fid, '%d\n', is_single); % run localization per event or per event list
fprintf(fid, '%s\n', plant);
fprintf(fid, '%s\n', sup);
if(is_single == 1)
    fprintf(fid, '%d\n', num_loc);
    for i = 1: num_loc
        fprintf(fid, '%d\n', eventlist(i));
        fprintf(fid, '%s\n', char(loc(i,2)));
    end
else
    fprintf(fid, '%s\n', char(loc(1,2)));
    for i=1:length(eventlist)
        fprintf(fid, '%d\n', eventlist(i));
    end
end
fclose(fid);
%--------------------------------------------------------------------------

% call TCT procedure localize
tic
cmdline = strcat(tct_name, ' -cmdline');
toc
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
if (is_single == 1)
    for i = 1: num_loc
        full_name = strcat(path, '\');
        full_name = strcat(full_name, char(loc(i,2)));
        full_name = strcat(full_name, '.DES');
        
        if ~exist(full_name, 'file')
            err_info(2) = 4;
            printerror(char(loc(i,2)));
            return;
        end
    end
else
        full_name = strcat(path, '\');
        full_name = strcat(full_name, char(loc(1,2)));
        full_name = strcat(full_name, '.DES');
        
        if ~exist(full_name, 'file')
            err_info(2) = 4;
            printerror(char(loc(1,2)));
            return;
        end
end

printerror;

if(is_single == 1)
    des_size = zeros(num_loc,2);
    for i = 1: num_loc
        [des_size(i,1), des_size(i,2)] = getdes_parameter(char(loc(i,2)));
    end
else
    [state_size, tran_size] = getdes_parameter(char(loc(1,2)));
end



%--------------------------------------------------------------------------
% write the result into makeit file
if(is_single == 1)
    for i = 1: num_loc
        fid = fopen('tmp.$$$', 'w');
        if fid == -1 % cannot open the specified file
            err_info(2) = 1;
            printerror('tmp.$$$');
            return;
        end
        if(mode == 1)
            if(eventlist(i) < 1000)
                fprintf(fid, '%s = Old_Localize(%s,%s,%d)',char(loc(i,2)), plant, sup, eventlist(i));
            else
                fprintf(fid, '%s = Old_Localize(%s,%s,MARK)',char(loc(i,2)), plant, sup);
            end
        else
            if(eventlist(i) < 1000)
                fprintf(fid, '%s = New_Localize(%s,%s,%d)',char(loc(i,2)), plant, sup, eventlist(i));
            else
                fprintf(fid, '%s = New_Localize(%s,%s,MARK)',char(loc(i,2)), plant, sup);
            end
        end
        
        fprintf(fid, '  (%d,%d)\n', des_size(i,1), des_size(i,2));
        
        if (timer == 1)
            fprintf(fid, '      Computing time = %d\n\n',toc);
        end
        
        fclose(fid);
        mergechop(length(char(loc(i,2))) + 3);
    end
else
    fid = fopen('tmp.$$$', 'w');
    if fid == -1 % cannot open the specified file
        err_info(2) = 1;
        printerror('tmp.$$$');
        return;
    end
    if(mode == 1)
        fprintf(fid, '%s = Old_Localize(%s,%s,[',char(loc(1,2)), plant, sup);
        for i = 1: length(eventlist)
            fprintf(fid, '%d', eventlist(i));
            if i < length(eventlist)
                fprintf(fid, ',');
            end
        end        
        fprintf(fid, '])');
    else
        fprintf(fid, '%s = New_Localize(%s,%s,[',char(loc(1,2)), plant, sup);
        for i = 1: length(eventlist)
            fprintf(fid, '%d', eventlist(i));
            if i < length(eventlist)
                fprintf(fid, ',');
            end
        end        
        fprintf(fid, '])');
    end
    
    fprintf(fid, '  (%d,%d)\n', state_size, tran_size);
    
    if (timer == 1)
        fprintf(fid, '      Computing time = %d\n\n',toc);
    end
    
    fclose(fid);
    mergechop(length(char(loc(1,2))) + 3);
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