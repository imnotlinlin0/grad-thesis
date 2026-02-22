
% SAVE_TS - This file will save in ascii format all of the of the tseries
% formatted data items presented to it.
%
% Usage:
%
% save_ts(file_name, tseries1,tseries2,etc)
%
% where
% 
% file_name: name of file to data to
% tseriesX: name of timeseries variables to save

function file_name = save_ts(name, varargin)

%Test that all variables have same frequency
for j = 2:length(varargin)
    if varargin{j}.freq ~= varargin{j-1}.freq
        error(['Frequency mismatch: ', varargin{j}.name, ' has frequency ', num2str(vararging{j}), '.']);
    end
end



fid = fopen(name, 'w');

counter = ones(size(varargin,2),1);


%Used to find the earliest starting ts
start_date = counter;  %Intialize start_date
for i = 1:size(start_date,1)
    start_date(i) = varargin{i}.sd;
end
cur_date = min(start_date);

%Insert Series Titles
fprintf(fid, '%s\t', ' ');
for i = 1:size(counter,1)

    fprintf(fid, '%.15s\t', varargin{i}.name(1:min([15, size(varargin{i}.name,2)])));
end
fprintf(fid, '%s\n' , '');

j =1;
while j > 0 
    %Insert Dates
    fprintf(fid, '%s\t', num2str(cur_date));
    
    %Insert Data
    for i = 1:size(counter,1)
        if cur_date < varargin{i}.sd || counter(i)<0
            fprintf(fid, '%9s\t', 'NaN     ');
        else
            fprintf(fid, '%6.5f\t', varargin{i}.dat(counter(i)));
            %Test if at end of series
            if counter(i) == size(varargin{i}.dat,2)
                counter(i) = -1;
            else
            counter(i) = counter(i)+1;
            end
        end
    end
    fprintf(fid, '%s\n', ' ');
    cur_date = index(cur_date,1,varargin{1}.freq);
    j = max(counter);
end


fclose(fid);
