%function init();
function init(varargin)

global path;
global prm_file;
global makeit_file; 
global rst_file;

if nargin == 1 && strcmp(path,upper(varargin{1}))
    return;
end

path = '';
if nargin == 1
    path = varargin{1}; 
end

if isempty(path)
    % Check if the ctct.ini file exists
    if ~exist('ctct.ini', 'file')
        path = 'user';
    else
        fid = fopen('ctct.ini', 'rt');
        if fid == -1 % cannot open the specified file
            path = 'user';
        else
            path = fgets(fid);
            fclose(fid);
            if strcmp(path(length(path)),char(13)) || strcmp(path(length(path)),char(10))
                path(length(path)) = '';                
            end
        end
    end
end

path = upper(path);

fid = fopen('ctct.ini', 'wt');
if fid ~= -1 % cannot open the specified file
    fprintf(fid, '%s\n', path);
    fclose(fid);
end

if ~exist(path, 'dir')
    mkdir(path);
end

 % set directory of prm_file, which stores the information for calling TCT functions
prm_file = strcat(path,'\ctct.prm');

 % set directory of rst_file, which stores the result of executing TCT functions
rst_file = strcat(path,'\ctct.rst');

% set directory of makeit file
makeit_file = strcat(path, '\MAKEIT.TXT');

end %function
% the end -----------------------------------------------------------------