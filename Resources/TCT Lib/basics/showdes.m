% show(name1)
function showdes(name1)
global path;
%global err_info;

%if err_info(2) ~= 0
%    return;
%end

% check if the file to be created exists
full_name = strcat(path, '\');
full_name = strcat(full_name, name1);
full_name = strcat(full_name, '.GIF');

%if ~exist(full_name, 'file')
%    err_info(2) = 4;
%    return;
%end

% show the generated figure

[I, map] = imread(full_name);
imshow(I, map);

% the end -----------------------------------------------------------------