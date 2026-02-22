function ts_out = ts_base(ts_in, base_per)


start = ts_in.sd;
ed    = ts_in.ed;
freq  = ts_in.freq;
dat   = ts_in.dat;

%Make a column of dates
date_col = zeros(length(dat),1);
date_col(1) = start;
for j = 1:length(dat)
   date_col(j+1) =  MQ_index(date_col(j), 1, freq);
end

idx_base = find(base_per==date_col);

ts_out = ts_in;

ts_out.dat = 100*dat./(dat(idx_base));