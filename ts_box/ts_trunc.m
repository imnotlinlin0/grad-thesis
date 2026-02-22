function ts_in = ts_trunc(ts_in,date_range)

ts_in.dat = vect(ts_in,0,date_range);
ts_in.sd = date_range(1);
ts_in.ed = date_range(2);