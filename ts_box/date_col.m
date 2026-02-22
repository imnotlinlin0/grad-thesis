% DATE_COL - Create a column of dates for use outputing TS object
%
% usage:
%
% out = date_col(date_range, freq)
%
% where
%
% date_range = 1x2 date range vector (e.g. [194901, 200704])
% freq = the number of observations per year (e.g. 4 = quarterly);


function out = date_col(dr,freq)

start = dr(1);
ender = dr(2);

start_y = floor(start/100);
per_start = mod(start,100);
end_y = floor(ender/100);
per_end = mod(ender,100);

nper = (end_y-start_y)*freq+per_end-per_start+1;


out = zeros(nper,1);
out(1) = start;

for j = 1:nper-1
   out(j+1) =  MQ_index(out(j), 1, freq);
end
