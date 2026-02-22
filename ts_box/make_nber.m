%MAKE_NBER - File used to make the series save in NBER_rec.mat



function make_nber


dat = xlsread('NBER_dates.xls');
sd = 191101;
NBER = ts_make(dat(:,2),12,sd);

save NBER_rec NBER
