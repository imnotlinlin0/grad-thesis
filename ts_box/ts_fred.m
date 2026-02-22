function out = ts_fred(in)

date_str = strtrim(in.DateRange);


if strcmp(strtrim(in.Frequency), 'Monthly')
    per = 12;
    st = 100*str2num(date_str(1:4))+str2num(date_str(6:7));
elseif strcmp(strtrim(in.Frequency), 'Quarterly')
    per = 4;
    st = 100*str2num(date_str(1:4))+ceil(str2num(date_str(6:7))/3);
elseif strcmp(strtrim(in.Frequency), 'Annual')
    per = 1;
    st = 100*str2num(date_str(1:4))+1;
else
    error('Unkown Freq');
end


out = ts_make(in.Data(:,2),per,st,strtrim(in.Title));
out.unit = strtrim(in.Units);
