% TS_WAVERAGE
% out = ts_Waverage(whgts,s1, s2, s3, ...)
%
% weighted average of ts objects, ignoring NaNs
%
% caution: assumes frequency is the same and that date_range is determined
% by first argument.

function [ts_out,wghts] = ts_waverage(wghts,varargin)

N1 = numel(varargin);
N2 = numel(wghts);

if N2>N1
    warning('Number of weights > Number of TS');
    wghts = wghts(1:N1);
elseif N1>N2
    error('Number of TS > number of weights');
end

date_range = [varargin{1}.sd,varargin{1}.ed];

dat_out = 0*vect(varargin{1},0,date_range);

%Get the data out of the TS objects for aligned periods
T = size(dat_out,1);
dat_set = zeros(T,N1);
for jj = 1:N1
   dat_set(:,jj) = vect(varargin{jj},0,date_range);
end

%Weights for each observation
wghts = repmat(wghts(:)',[T,1]);

%Check for NaN to drop and redo the weights;
wghts(isnan(dat_set))  = 0;
dat_set(isnan(dat_set)) = 0;
wghts = wghts./sum(wghts,2);

dat_out = sum(wghts.*dat_set,2);

ts_out = ts_make(dat_out,varargin{1}.freq,date_range(1),'Averaged TS');
