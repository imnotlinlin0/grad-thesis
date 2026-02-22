% NUM2Q - Converts a date number to its year-quarter equivalent
%
% usage:
%
% out = Num2Q(date_num)
% 
% where
% 
% date_num = a matlab formatted date number
%
% out = a date in quarter-number format - e.g. 2005 Q4 is 200504





function out = Num2Q(date_num)

year = str2num(datestr(date_num, 'yyyy'));
q = floor(str2num(datestr(date_num, 'mm'))/3)+1;

out = 100*year+q;