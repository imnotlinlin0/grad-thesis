%TS_MINUS
%out = ts_minus(s1, s2)

function out = ts_plus(s1, s2)

if ~isstruct(s2)
    out = s1;
    out.dat = out.dat*s2;
    
else
    %Check to make sure of same freq
    if s1.freq ~= s2.freq
        error('Incompatible timeseries frequencies.');
    end
    
    
    %Used to find the earliest starting ts
    start = max(s1.sd, s2.sd);
    ender = min(s1.ed, s2.ed);
    
    
    %Get the overlapping data, divide
    dat1 = vect(s1, 0, [start, ender]);
    dat2 = vect(s2, 0, [start, ender]);
    dat = dat1-dat2;
    
    %make new tseries
    out = ts_make(dat,s1.freq,start, [s1.name '-' s2.name]);
end