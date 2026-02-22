%TSDELTA - First-difference a timeseries

function out = tsdelta(ts)
  ts.dat = [ts.dat(1) ts.dat(2:end) - ts.dat(1:end-1)];
  out = ts;