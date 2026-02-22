function newd = tsshift(tsd,k,freq)

% Shift a timeseries date at freq forward or back by k periods
% Syntax:  newdate = tsshift(tsdate,k,freq)

  dy = fix(tsd/100);
  df = round(rem(tsd/100,1)*100);
  dfnew = df + k;
  if(dfnew>0)
	adddy = fix((dfnew-1)/freq);
	adddf = dfnew - freq*adddy;
  else
	adddf = round(freq*(1+rem(dfnew/freq,1)));
	adddy = fix((dfnew-freq)/freq);
  end
  newd = 100*(dy+adddy) + adddf;
