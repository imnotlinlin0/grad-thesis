% TS_MAKE - Make a ts object from data vector
%
% usage
%
% ts = ts_make(data,freq,startdate,name)
%
% where
%
% data = a vector of data for the tseries (colum or row)
% freq = the number of observations per year (eg, 1, 4, 12)
% startdate = the start year and quarter, eg (195404)
% name = a text label describing the data in detail 


function out = ts_make(data, freq, startdate, varargin)

if size(data,1) > size(data,2)
    data = data';
end

out.dat = data;
out.freq = freq;
out.sd = startdate;
out.ed = MQ_index(startdate, length(data)-1, freq);

if length(varargin)>0
    out.name = varargin{1};
else
    out.name = 'timeseries';
end

