%This function sets and save a var dateRange so that it can be accessed at any time

function setDateRange (startDate, endDate)

if 2 == exist('home_dir')
    dateRange = [startDate, endDate];
    save ([home_dir, 'ryan_lib/ts_box/dateRange dateRange']);
else
    error('Home directory not defined.  Please use setHomeDir');
end
