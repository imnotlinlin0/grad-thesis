%SAVE_TS - This file will save in ascii format all of the of the tseries
%formatted data items presented to it.
%
%Usage:
%save_ts(file_name, tseries1,tseries2,etc)


function file_name = save_ts(varargin)

%Print format option
if isstr(varargin{1})
    print_format = varargin{1};
    varargin = varargin(2:end);
else
    print_format = '%3.1f\t';
end

nser = length(varargin);
starts = zeros(nser,1);
ends = zeros(nser,1);

%Used to find the earliest starting ts
for i = 1:nser
    starts(i) = varargin{i}.sd;
    ends(i) = varargin{i}.ed;
    freq(i) = varargin{i}.freq;
end
start = min(starts);
ender = max(ends);

%Check to make sure of same freq
if ~sum(freq==freq(1))==length(freq)
    error('Incompatible Frequencies');
else
    freq=freq(1);
end

%How many periods
start_y = floor(start/100);
per_start = mod(start,100);
end_y = floor(ender/100);
per_end = mod(ender,100);

nper = (end_y-start_y)*freq+per_end-per_start+1;

%Make a column of dates
date_col = zeros(nper,1);
date_col(1) = start;
for j = 1:nper-1
   date_col(j+1) =  MQ_index(date_col(j), 1, freq);
end

data = NaN*zeros(nper, nser);
%Make data cols
for j = 1:nser
    idx1 = find(date_col==starts(j));
    idx2= find(date_col==ends(j));
    data(idx1:idx2,j) = varargin{j}.dat;
end


%Print data
for j = 1:nper
    str = [sprintf('%.0f\t', date_col(j)), sprintf(print_format, data(j,:))];
    disp(str);
end
