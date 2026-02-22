function gx = pctchange(x,lg)

% gx = rategrow(x,lg)
%
%      	computes the simple percentage change for timeseries "x" 
%	at lag "lg".


freq = x.freq;
if(freq==1)
	freq_word = 'year';
elseif(freq==4)
	freq_word = 'quarter';
elseif(freq==12)
	freq_word = 'month';
end

gx = scats(scats(tsdiv('all',x,lag(x,lg)),1,2),100,3);

nam = [num2str(lg),'-',freq_word,' pct. change in ',Get_Name_ts(x)];
gx = Rename_ts(gx,nam);
