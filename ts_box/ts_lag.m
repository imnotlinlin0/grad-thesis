function lagv = lag(v,k)

% Syntax:  lagv = lag(v,k)
%
% "Lag" a vector or timeseries v by k periods, i.e. shift it right by k periods, 
% padding the beginning with k zeros. Negative lags are allowed; in
% this case, the lead function is called. If the lag is 0, v is
% returned unharmed. If no lag is specified, the default lag is 1.

% Default for lag argument k is 1

if(nargin==1)
   k = 1;
end

if(k<0)

	sd = index(v.sd,k,v.freq)
    
    lagv = ts_make(v.dat,v.freq,sd,v.name);

elseif(k==0)
    
	lagv = v;   

else


	[nrows,ncols] = size(v);

	% Check to see if v is a timeseries

	tsflag = 1;%tschk(v);

	if(tsflag)

		% For timeseries, lagged series is just same data as
		% original series but starting at the original startdate
		% shifted forward k periods.

		savev = v;
		freq = v.freq;
		sd  = v.sd;
		v = v.dat;

		% Store back in timeseries matrix with new start date if input is a
		% timeseries matrix 

		sd = tsshift(sd,k,freq);   % New startdate

		kstr = int2str(k);
		lkstr = length(kstr);
		v = ts_make(v,freq,sd,['L',kstr,'(',setstr(savev.name),')']);  

		lagv = v;

	else

		% Transpose column vectors for shiftright operation

		if(nrows > ncols)
		  v = v';
		end

		lagv = shiftright(v,k);

		% Put result back into column vector form if original was a column
		% vector 

		if(nrows > ncols)
		  lagv = lagv';
		end

	end

end
