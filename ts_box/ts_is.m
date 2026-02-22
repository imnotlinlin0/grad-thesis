%Is the object a valid timeseries?

function out = ts_is(ts)

out = true;

try
    ts.freq;
catch
    out = false;
end

try
    ts.dat;
catch
    out = false;
end

try
    ts.sd;
catch
    out = false;
end

try
    ts.name;
catch
    out = false;
end

