%Take a time series with occaisonal missing values, and HP filter it.

function [xdev,xin] = ts_hp(xin,lam)

dat = xin.dat(:);
nan_idx = isnan(dat);

dat_tmp = dat;
dat_tmp(nan_idx) = nanmean(dat) + 0*randn(1,sum(nan_idx));

crit = 1;
jj = 1;
while crit > 1e-12
   
    [trnd] = hpfilter(dat_tmp,lam);
    
    dat_new = dat;
    dat_new(nan_idx) = trnd(nan_idx);
    
    crit = max(abs(dat_new-dat_tmp));
    %disp(num2str(crit));
    
    dat_tmp = dat_new;
    jj = jj+1;
end

xdev = xin;
xin.name = ['HP trend of ' xin.name];
xdev.name = ['HP-filtered ' xdev.name];
[xin.dat,xdev.dat] = hpfilter(dat_tmp,lam);
