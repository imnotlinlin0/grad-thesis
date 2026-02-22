%GET_TS_END - Gets the last date in a timeseries


function out = get_ts_end(ts)
out = index(ts.sd, max(size(ts.dat))-1, ts.freq);
