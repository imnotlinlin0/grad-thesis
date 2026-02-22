% PERIOD_CT - This  function is used to see how many time periods 
% between date and startDate, counting startDate as t = 1.
%
% Usage x = period_ct(start_date, end_date, quarters_per_index)
% 
% quarters_per_index - optional - typically 4 or 12

function count = period_ct(startDate, date, varargin)
    if isempty(varargin)
        periods = 1;
    else
        periods = varargin{1};
    end

    count.y = startDate;
    count.index = 1;
    while count.y < date
        count.y = index(count.y,1, periods);
        count.index = count.index +1;
    end
