function series = fit_frame( series, freq, series_s, series_e , start , stop )
%fits series into arbitrary time frame, truncating as needed or filling
%missing values with nan's
%multiple vars are allowed in the 2nd dimension, time must be 1st dimension (i.e, rows)
%
% e.g. fit_frame( ts, 4, [1970,2], [1999,1], [1960,1], [1989,4] )
% would fit ts into a time frame of 1960:Q1 to 1989:Q4, assuming a
% quarterly frequency (freq=4) and assuming that ts runs from 1970:Q2 until
% 1999:Q1
%
% written June 15, 2013, by Robert Ulbricht

dim = size(series,2);

if (series_s-start)*[freq;1] < 0
    series(1:(start-series_s)*[freq;1],:) = [];
else
    series = [ nan((series_s-start)*[freq;1],dim) ; series ];
end

if (series_e-stop)*[freq;1] > 0
    series = series(1:(stop-start)*[freq;1]+1,:);
else
    series = [series; nan((stop-series_e)*[freq;1],dim)];
end
