function  z = tsdiv(t1,t2, varargin);

% Syntax:  z = tsdiv(tsrange,t1,t2)
% Divide timeseries t2 into t1, store the result in
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

nam1 = Get_Name_ts(t1);
nam2 = Get_Name_ts(t2);
ops1 = ops_chk(nam1);
ops2 = ops_chk(nam2);

if(ops1&ops2)
	desc = ['(',nam1,') / (',nam2,')'];
elseif(ops1&~ops2)
	desc = ['(',nam1,') / ',nam2];
elseif(~ops1&ops2)
	desc = [nam1,' / (',nam2,')'];
else
	desc = [nam1,'/',nam2];
end

freq = Get_Freq_ts(t1);
[t1,err1] = tsproject(t1,tsrange(1),tsrange(2));
if(err1)
	error('Invalid tsrange for first series.')
end
[t2,err2] = tsproject(t2,tsrange(1),tsrange(2));
if(err2)
	error('Invalid tsrange for second series.')
end
z = Get_Data_ts(t1)./Get_Data_ts(t2);

z = tseries(z,tsrange(1),freq,desc);
