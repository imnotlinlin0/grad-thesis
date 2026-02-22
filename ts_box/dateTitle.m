% This function will take the date format yyyyqq and convert it into one of a types of
% date format title.  Possible arguments to pass:
% 'qDetail' 'Table1'
% 'Long' - 2004:Q1, 2004:Q2, etc
% Usage:
% date = dateTitle(date, format)

function [date, year] = dateTitle(date, format)
switch format

    case{'qDetail'}
        year = floor(date/100);

        quarter = mod (date,100);

        %When to add the year and ':'
        switch quarter
            case{1}
                date = [num2str(year),':Q1'];
            case{2,3,4}
                date =['Q',num2str(quarter)];
            otherwise
                warning('Attempted to convert yyyyqq to title where qq was not 1,2,3 or 4');
        end
    case{'Table1'}
        year = floor(date/100);
        quarter = mod (date,100);
        date =['Q',num2str(quarter)];
    case{'Long'}
         year = floor(date/100);
        quarter = mod (date,100);
        date = [num2str(year),':Q', num2str(quarter)];
end

