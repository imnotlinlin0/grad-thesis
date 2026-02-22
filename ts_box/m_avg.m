% M_AVG - function takes either a vector, a matrix or a (Jeff Fuhrer)
% timeseries and creates a moving average across n periods, including the
% current period.
% Usage:
% p = m_avg(in, n) where n is the input item and n is the number of time
% periods.



function out = m_avg(in,n)

%Seperate out data if a tseries
if isa(in, 'struct')
    data = in.dat';
else
    data = in;
end
%Initialize out to exclude the first n-1 obs, where n is the number
%of periods to lag.
out = zeros(size(data,1)-n-1, size(data,2));

%Do the calculation
for i = n:size(data,1)
    out(i-n+1, :) =  mean(data(i:-1:i-n+1,:));
end
    
if isa(in, 'struct')
    in.sd = index(in.sd,n-1);
    in.dat = out';
    out = in;
end

