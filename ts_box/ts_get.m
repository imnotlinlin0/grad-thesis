%ts_get



function out = ts_get(ts, varargin)


if length(varargin) == 0
    date_range = getDateRange;  
else
    date_range = varargin{1};
end
x = date_range 
[first, last] = find_ts_ends(ts, date_range);

out = ts.dat(first:last, :);

%FINDENDS - Finds the indecies that mark the data within the dateRange.
%Usage:
%[first, last] = findEnds(tseries, dateRange(optional)
%
% Uses system (getDateRange) date range if none is specified.

function [first, last] = find_ts_ends (data, dateRange)


tsStart = data.sd;

first = 1;

%Check starts date.
if dateRange(1) <tsStart
    error(['Data in ' data.name, ' begins after start of date range.  Rest date range using setDateRange().'])
end

while tsStart <dateRange(1)
    first= first+1;
    tsStart = MQ_index(tsStart,1,data.freq);
end
last = first;

while tsStart < dateRange(2)
    last = last+1;
    tsStart = MQ_index(tsStart,1,data.freq);
end

if last > size(data.dat)    
      error(['Data series ', data.name, ' (End Date:' , num2str(index(data.sd,size(data.dat,1)-1)),') does not extend to end of date range (End Date:', num2str(dateRange(2)), '.) Reset date range using setDateRange().']);
end
