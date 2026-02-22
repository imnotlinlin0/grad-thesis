function  z = tssub(t1,t2,varargin);

% Syntax:  z = tssub(tsrange,t1,t2)
% Subtract timeseries t2 from t1, store the result in
% z, and name the series appropriately.
%
% NOTE: This version overloads Jeff Fuhrer's version. (Modified by Ryan
% Chahrour, May, 2006 to no require a tsrange argument.)

if ~isempty(varargin)
    tsrange = varargin{1};
else
    tsrange = 'all';
end

tsflg = tschk(t1);
if(~tsflg)
	error('Not a timeseries.  Bail out.')
end

if(strcmp(tsrange,'all'))
	% Find maximum overlapping tsrange
	tsmax = [Get_Start_ts(t1),Get_End_ts(t1)];
	ts2 = [Get_Start_ts(t2),Get_End_ts(t2)];
	if(ts2(1)>tsmax(1))
		tsmax(1) = ts2(1);
	end
	if(ts2(2)<tsmax(2))
		tsmax(2) = ts2(2);
	end
	tsrange = tsmax;
end

desc = [Get_Name_ts(t1),'-',Get_Name_ts(t2)];
freq = Get_Freq_ts(t1);
[t1,err1] = tsproject(t1,tsrange(1),tsrange(2));
if(err1)
	error('Invalid tsrange for 1st series.')
end
[t2,err2] = tsproject(t2,tsrange(1),tsrange(2));
if(err2)
	error('Invalid tsrange for 2nd series.')
end
z = Get_Data_ts(t1) - Get_Data_ts(t2);

z = tseries(z,tsrange(1),freq,desc);
