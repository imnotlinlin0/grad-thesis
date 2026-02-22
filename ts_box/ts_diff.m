%TS_DIFF
%out = ts_div(s1)

function out = ts_diff(s)



%Get the data
dat = vect(s, 0, [s.sd, s.ed]);
dat = dat(2:end)-dat(1:end-1);

%make new tseries
out = ts_make(dat,s.freq,index(s.sd,1,s.freq), ['deta ' s.name]);
