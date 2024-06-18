% Declare the global variables and add the basic libs
% Date: 2018.07.05

global tct_name;
global path;
global prm_file;
global makeit_file; 
global rst_file;
global err_info; 
global timer;

% Set the full name of TCT (including the suffix) in the work directory
tct_name = 'Resources\TCT64.exe';

% Initialize other global variables
path = '';
prm_file = '';
rst_file = '';
makeit_file = '';

% initialize the error information
err_info = [0,0]; % the first bit store the code of the executing procedure,
                  % the second stores the code of the erro type

% add TCT Lib to the search directories
addpath('Resources\TCT Lib\');
addpath('Resources\TCT Lib\basics\');
% addpath('Resources\TEST Lib');

timer = 1;

% the end -----------------------------------------------------------------