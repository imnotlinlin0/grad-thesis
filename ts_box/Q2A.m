% NOT FINISHED! M2Q - Convert data to quarterly observations from monthly using arithmetic mean.
%
% usage
%
% out = QtoA(data, start_date, options)
%
% where 
% 
% data  = a matrix of data with quarterly observation along the columns
% start_date = a matlab date number corresponding to the first observation
%
% out = quarterly averaged values
% start = a number with year-quarter format (e.g. 2003Q4 is 200304)
%
%
% IMPORTANT NOTES: Partial quarters will be returned as NaN, as will quarters with
% any missing values.  Options arguments are not yet defined.



function [out] = Q2A(data)
sd = data.sd;
ed = data.ed;
if ts_is(data)
    ts = data;
    data = ts.dat;
end

if size(data,1)<size(data,2)
    data = data';
end

%Starting year
sd = 100*floor(sd/100)+1;

%Get starting Q
start_q = mod(sd,100);
end_q   = mod(ed,100);

%Pad partial years with NaN's
data_pad = [NaN(start_q-1,1);data;NaN(4-end_q,1)];
data_pad = nanmean(reshape(data_pad,[4,length(data_pad)/4]));

%New TS
out = ts_make(data_pad,1,sd, ts.name);

