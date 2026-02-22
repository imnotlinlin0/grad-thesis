% Q2M - Expand a quarterly data to monthly frequency
%
% usage:
%
% out = Q2M(ts)
%
% where: 
% 
% ts = a quarterly timeseries object
%
% out = a monthly timeseries object, where the values are the same within each quarter



function [out] = Q2M(data)

if ts_is(data)
    ts = data;
    data = ts.dat;
else
    error('Input argument must be a timeseries object');
end

%Variables to use later
nq = length(data);
sd = ts.sd;  
sq = rem(sd,100);   
sm = 1 + 3*(sq-1); 


%Replace data
ndat = zeros(1, 3*nq);
for j = 1:nq
    ndat((j-1)*3+1:j*3) = data(j);
end

%Return output argument
out = ts_make(ndat,12,sd-sq+sm, ts.name); 
    
