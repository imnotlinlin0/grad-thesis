%EXCEL_MAT_DATE: Converts an excel date number to a matlab date number.
%
%usage:
%out = excel_mat_date(input, direction(optional)
%
%where
%input = the date number to convert
%direction = specifies the direction of the conversion ('to matlab' or 'to
%            excel'.) 'to matlab' is the default   
%May not work in windows.


function out = excel_mat_date(input, varargin)


%This number is the difference in reference dates between the two programs.
%Add this to excel to get the matlab a datenumber
dif = 693960;

if isempty(varargin) || strcmpi(varargin{1}, 'to matlab')
    %Convert to matlab number
    out = input+dif;
elseif strcmpi(varargin{1}, 'to excel')
    out = input - dif;
else
    error('Invalid direction argument in excel_mat_date.  See help file.');
end





