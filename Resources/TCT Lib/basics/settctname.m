%function settctname();
function settctname(tctname)

global tct_name;

% Set the full name of TCT (including the suffix) in the work directory
tct_name = strcat(tctname,'.exe');

end %function
% the end -----------------------------------------------------------------