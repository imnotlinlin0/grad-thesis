%ts_interpolate


function out = ts_interp(ts, new_freq, varargin)




if ~isempty(varargin)
    method = varargin{1};
else
    method = 'con_growth';
end


%Initialize data
dat = ts.dat;
p_per_p = new_freq/ts.freq; %"Periods per period"
new_dat = zeros((length(dat)-1)*p_per_p,1);
switch method
    
    case {'con_growth'}
    grwth = dat(2:end)./dat(1:end-1);
    new_dat(1) = dat(1);
    for j=0:length(grwth)-1
        for k = 1:p_per_p
            new_dat(1+k+p_per_p*j) = new_dat(k+j*p_per_p)*(grwth(j+1).^(1/p_per_p));
        end
    end
        
        
    otherwise
end


out = ts;
out.freq = new_freq;
out.dat = new_dat;