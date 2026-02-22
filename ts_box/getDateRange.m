% GETDATERANGE - Gets Date Range
% This function gets the current date ranges, which has been set be
% setDateRange.
% Usage:  
% date_range = getDateRange()


function date_range = getDateRange()

if 2 == exist('home_dir')
    load([home_dir, 'ryan_lib/ts_box/dateRange dateRange']);
    date_range = dateRange;
else
    error('Home directory not defined.  Please use setHomeDir');
end
