% GETENDDATE - finds the end date of a timeseries
% usage:
% endDate = getEndDate(ts)
% where
% ts = a time series a la Jeff Fuhrer

function ed = getEndDate(data)

ed = data.sd;
for i = 2:size(data.dat,2)
    ed = index(ed,1,data.freq);
end
