%PCT - Uses Jeff's program to compute percent changes, with the addition
%of allowing users to "annualize" rate for n periods.
%Usage:
%PCN(ts, lag, n) where
%ts = a timeseries of data(now also works for a vector)
%lag = the number of periods back to use as reference
%n = the number of periods to extrapolate rate, optional ("annualized number")


function p = pct(ts, lag, varargin)

%Seperate out data if a tseries
if isa(ts, 'struct')
    data = ts.dat;
else
    data = ts;
end

if size(varargin,2) == 1
    n = varargin{1};
    data = 100*((data(:,lag+1:end)./data(:,1:end-lag)).^n - 1);
    if isa(ts, 'struct')
         p = tseries(data',index(ts.sd, 1, ts.freq),ts.freq,['Change in ', ts.name]);
    else
        p = data;
    end
    
else
    data(:,1:end-lag);
    data(:,lag+1:end);
    n = 1;
    data = 100*((data(:,lag+1:end)./data(:,1:end-lag)).^n - 1);
    if isa(ts, 'struct')
         p = tseries(data',index(ts.sd,1, ts.freq),ts.freq,['Change in ', ts.name]);
    else
        p = data;
    end
end
   
    

