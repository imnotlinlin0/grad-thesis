%TSDETREND - Detrends a time series with a constant, a time trend and
%optional break points.
%
%usage
%
%tsdetrend(ts, date_range(optional), break_points(optional))
%
%where
%
%ts - a (jeff fuhrer) time series
%date_range - an optional date range eg [195001 200201].  If not used, will
%             used function 'getDateRange' to determine the date range
%break_points - pick the break points you would like to use. As many as you
%             want.

function out = tsdetrend(ts,varargin)

bp = [];
 
%Handle input arguments.
if ~isempty(varargin)

    %The first optional argument is either a date Range of break point
    if size(varargin{1},2) == 2
        date_range = varargin{1};
    elseif ischar(varargin{1})
        date_range(1) = ts.sd;
        date_range(2) = index(ts.sd, size(ts.dat,2)-1, ts.freq);
        for j = 2:size(varargin,2)
            bp(j-1) = varargin{j};
        end
    else
        date_range = getDateRange;
        bp(1) = varargin{1};
        for j = 2:size(varargin,2)
            bp(j) = varargin{j};
        end
    end
else
    date_range = getDateRange;
end

%Intialize some RHS variables.
data = vect(ts,0,date_range);

%Get other trends
trends = zeros(size(data,1),size(bp,2));
for i = 1:size(bp,2);
    %Get the trend of the segemented trend
    counter1 = period_ct(bp(i),date_range(2));
    half2 = (1:counter1.index)';
    counter2 = period_ct(date_range(1),index(bp(i),-1, ts.freq));
    trends(counter2.index+1:end,i) = half2;
end

%A constant, full trend and the extra trends are the rhs variables.
rhs = [ones(size(data,1),1), (1:size(data,1))', trends];

%Regress with these
reg1 = reg(data,rhs, 'fast');

%The residuals are the detrended data
new_data = get_reg(reg1, 'resid');

%Make the detrended series.
out = tseries(new_data, date_range(1), 4, ['Detrended ', ts.name]');
