%DATE_LABEL: This function creates a cell array that includes, as strings, all the
%dates included in DateRange.  Type help setDateRange to learn more about
%date range.
%Usage:
% a = date_label()
    

function a = date_label()
a = {};
i = 1;
range = getDateRange;

fid = fopen('dates', 'w')
while range(1) <= range(2)
    a{i} =  dateTitle(range(1),'Long');
    fprintf(fid, '%s\n', dateTitle(range(1),'Long'));
    range(1) = index(range(1));
    i = i+1;
end
fclose(fid);