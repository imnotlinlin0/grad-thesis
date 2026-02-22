%This  function is used to see how many time periods between date and 
%startDate, counting startDate as t = 1.
%
%Usage x = DataCount(date, startDate, periods_per_year)

function count = DataCount(date, startDate, varargin)
    warning('all:outOfDate','DataCount is out of date.  Please use period_ct()');
    
    
    %If the data are not quarterly.
    if ~isempty(varargin)
        periods = varargin{1};
    else
        periods = 4;
    end
    
    %Count
    count.y = startDate;
    count.index = 1;
    while count.y < date
        count.y = index(count.y,1,periods);
        count.index = count.index +1;
    end
