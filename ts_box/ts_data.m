% FINDENDS - Finds the indecies that mark the data within the dateRange.
% 
% Usage:
% [first, last] = findEnds(tseries, date_range)

function [first, last] = findEnds (data, dateRange)
tsStart = data.sd;
freq = data.freq;
first = 1;


%Warning
warning('all:outOfDate', 'ts_data and findEnds are similar functions.  Please only use one of them.')

%Check starts date.
if dateRange(1) <tsStart
    error('Data begins after start of date range.  Rest date range using setDateRange().')
elseif dateRange(1)==tsStart
    warning('all:dateRangeWarning' , 'Data begins at first time period of datre range. Percent change cannot be calculated.')
end

while tsStart <dateRange(1)
    first= first+1;
    tsStart = index(tsStart);
end
last = first;

while tsStart < dateRange(2)
    last = last+1;
    tsStart = index(tsStart);
end

if last > size(data.dat)
    data
    error(['Data series ', data.name,' does not extend to end of date range. Reset date range using setDateRange().']);
end
