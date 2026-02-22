% M2Q - Convert data to quarterly observations from monthly using arithmetic mean.
%
% usage
%
% out = MtoQ(data, start_date, options)
%
% where 
% 
% data  = a matrix of data with monthly observation along the columns
% start_date = a matlab date number corresponding to the first observation
%
% out = quarterly averaged values
% start = a number with year-quarter format (e.g. 2003Q4 is 200304)
%
%
% IMPORTANT NOTES: Partial quarters will be returned as NaN, as will quarters with
% any missing values.  Options arguments are not yet defined.



function [out, start] = M2Q(data, varargin)

if ts_is(data)
    ts = data;
    data = ts.dat;
end

if size(data,1)<size(data,2)
    data = data';
end

t = size(data,1);
n = size(data,2);


    %Default option - assume start_date is a matlab date number
 
if length(varargin) == 1    
    %Start month
    start_date = varargin{1};
    m_start = str2num(datestr(start_date, 'mm'));
    y_start = str2num(datestr(start_date, 'yyyy'));
    start = Num2Q(start_date);
else
    y_start = floor(ts.sd/100);
    m_start = ts.sd-y_start*100;
    q = floor(m_start/3)+1;
    start = 100*y_start+q;
end
    
    start_idx = mod(m_start,3);
    end_idx = mod(t-start_idx+1,3);
    
    %Intialize
    out = zeros(floor((t-start_idx+1)/3), n);
    
    %Some fancy indexing
    for j = 1:size(out,1)
        dat_tmp = data(3*(j-1)+start_idx:3*(j-1)+start_idx+2,:);
        out(j,:) = mean(dat_tmp(~isnan(dat_tmp)));
    end
    
    %Append NaN for partial quarters
    if start_idx ~= 1
        out = [NaN*ones(1,n);out];
    end
    if end_idx ~= 0
        out = [out; NaN*ones(1,n)];
    end
    
    %Get the starting year-quarter
    
  
if exist('ts')
   out = ts_make(out,4,start, ts.name); 
end
    
