% INDEX - Adds one or more time periods to input time period.
% Assumes data is quarterly unless stated otherwise.
%
% Usage: index (yyyyqq, period_number, periods_per_year)
% where
% yyyyqq: 4-digit year and 2-digit period  (ie 199401 or 2000212)
% period_number: # of periods to index, neg numbers count back.(optional)
% periods_per_year: # of periods per year, typically 1,4 or 12.(optional)
%
% NOTE: Replaced by MQ_index - please convert code.

function i = index (i, varargin)
if size(varargin,2)>1
    per = varargin{2};
else
    per = 4;
end

if isempty(varargin)
    i = helper_plus(i,per);
elseif varargin{1} >= 0
    for j = 1:varargin{1}
        i = helper_plus(i,per);
    end
elseif varargin{1}<0
    for j = -1:-1:varargin{1}
        i = helper_min(i,per);
    end
end



function i = helper_plus(i,per)
temp = mod (i, 1900);
q = mod (temp, 100);
if q<per
    i = i +1;
else
    i = i+ 100 - (per-1); %+100 adds a year, -q, subtracts accumulated quaters
end




function i = helper_min(i,per)
temp = mod (i, 1900);
q = mod (temp, 100);
if q >1
    i = i -1;
else
    i = i-100+(per-1);
end
