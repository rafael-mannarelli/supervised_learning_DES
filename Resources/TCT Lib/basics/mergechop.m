% merge running information into MAKEIT.TXT in unified format
function mergechop(offset)
global makeit_file;

% generate the prm file for create DES
out = fopen(makeit_file, 'a+');

tempstr = zeros(1,offset);
for i = 1 : offset
    tempstr(i) = ' ';
end

in = fopen('tmp.$$$', 'r');%
col = 0;
while ~feof(in)
    str = fgets(in);
    n_str = length(str);
    for i = 1: n_str
        ch = str(i);
        col = col + 1;
        if strcmp(ch, '\n') == 1
            col = 0;   
        elseif col >= 75
            if strcmp(ch, '\n') == 0
                fprintf(out, '\n');
                fprintf(out, '%s', tempstr);
                col = offset + 1;
            end
        end
        fprintf(out, '%s', ch);
    end
end
fclose(out);
fclose(in);

% remove the temporary file
delete('tmp.$$$');

% the end