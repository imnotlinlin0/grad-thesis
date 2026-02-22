% TSMAVG - Creates time series moving avg
%
% Usage:
% out = tsmavg (ts, lag, weights)
% where
% ts = timeseries
% lag = the number of values (including current) to include in mavg
% weights = a matrix of weights to use for the moving average, optional

function out = tsmavg(ts, lag, varargin)
if size(ts.dat, 1) >1
    error ('TSMAVG does not support time series with multiple data series.');
end

if isempty(varargin)    
    ts.dat = movavg(ts.dat,lag); 
    ts.sd = index(ts.sd, lag-1,ts.freq);
else
    ts.dat = movavg(ts.dat,lag, varargin{1}); 
    ts.sd = index(ts.sd, lag-1,ts.freq);
end
out = ts;