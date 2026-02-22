%TS_AVERAGE
%out = ts_average(s1, s2, s3, ...)

function out = ts_average(varargin)

N = numel(varargin);
out = varargin{1};
for jj = 2:N 
    out = ts_plus(out,varargin{jj});
end
out.dat = out.dat/N;