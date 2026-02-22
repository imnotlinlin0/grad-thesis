%EXCEL_IN - Reads in excel data and returns the variables to the workspace.
%
% On the unix side, to use this, I must newer excel files once a text files
% then return to excel 5.0/95 to get to work with xlsread!
%
% Usage:
%
% ts_in(file, sheet,sd,freq,mat_file)
%
% where
% 
% ...

function ts_in(file,sheet,sd,freq, mat_file)
warning off
[data, text] = xlsread(file, sheet);
warning on
if size(data,2) == size(text,2)
    extra_var = 1;
%For the case where 1st column dates are numerical, and thus included in
%data matrix
    for i = 2:size(data,2)
        ts = ts_make(data(:,i),freq, sd, text{1, i});
        eval([next_tok(text{1,i}), '= ts;']);
    end

elseif (size(data,2)+1) == size(text,2)
    extra_var = 0;
%For the case where they are not numerical, and thus not included in the 
%data matrix.
    for i = 1:size(data,2)
        ts = ts_make(data(:,i), freq, sd, text{1,i+1});
        eval([next_tok(text{1,i+1}), '= ts;']);
    end

else
    error('Unexpected Excel Format');
end
disp(' ');
disp(['Excel_in succeeeded: ', num2str(i)-extra_var, ' variables entered.'])
disp(' ');
clear file
clear sheet
clear freq
clear sd
clear data
clear text
clear i
clear ts
clear out
clear ts
clear ans
save(mat_file);