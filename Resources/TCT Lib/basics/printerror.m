% print error according to the error code
function printerror(varargin)
global err_info;

if err_info(2) == 0
    fprintf('Succeed in executing ')
else
    fprintf('Failed at ');
end

switch err_info(1)
    case 0
        fprintf('create');
    case 1
        fprintf('selfloop');
    case 2
        fprintf('trim');
    case 3
        fprintf('sync');
    case 4
        fprintf('meet');
    case 5
        fprintf('supcon');
    case 6
        fprintf('mutex');
    case 7
        fprintf('condat');
    case 8
        fprintf('supreduce');
    case 9
        fprintf('minstate');
    case 10
        fprintf('complement');
    case 11
        fprintf('localize');   
    case 12
        fprintf('force');
    case 13
        fprintf('project');
    case 14
        fprintf('relabel');
    case 19
        fprintf('allevents');
    case 20
        fprintf('supnorm');
    case 21
        fprintf('supscop');
    case 22
        fprintf('supconrobs');        
    case 23
        fprintf('supqc');       
    case 24
        fprintf('isomorph');
    case 25
        fprintf('nonconflict');    
    case 26
        fprintf('observable');    
    case 27
        fprintf('natobs');        
    case 28
        fprintf('suprobs');        
    case 29
        fprintf('bfs_recode');
    case 30
        fprintf('diaplaydes');
    case 31
        fprintf('getdes_parameter');
    case 33
        fprintf('printdes');
    case 34
        fprintf('printdat');
    case 35
        fprintf('exlocalize');
end
if err_info(2) == 0
    fprintf('.\n');
    return;
else
    fprintf('; ')
end

switch err_info(2)
    case 1
        fprintf('cannot open %s', varargin{1});
    case 2
        fprintf('system error');
    case 3
        fprintf('out of memory');
    case 4
        fprintf('%s is not generated', varargin{1});
    case 5
        fprintf('no result generated');
    case 6
        fprintf('data entry error');
    case 7
        fprintf('%s.DES does not exist',varargin{1});
    case 8
        fprintf('%s.DAT does not exist',varargin{1});
end
fprintf('.\n');
% the end