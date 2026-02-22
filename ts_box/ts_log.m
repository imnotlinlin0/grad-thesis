%TS_DIV
%out = ts_log(s1)

function s1 = ts_log(s1)

s1.dat = log(s1.dat);
s1.name = ['log(' s1.name ')'];
