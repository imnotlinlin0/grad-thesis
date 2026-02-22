function [out_month] = D2M_Fred(Xin)

dates = Xin(:,1);
vals  = Xin(:,2);

year0  = str2num(datestr(dates, 'yyyy'));
month0 = str2num(datestr(dates, 'mm'));

year_range = year0(1):year0(end);
month_range = 1:12;
out = zeros(length(year_range)*4,1);

ctr = 1;
for yy = year_range
    for mm = month_range
        idx = ((year0==yy)+(month0==mm))==2;
        
        out(ctr) = nanmean(vals(idx));
        
    
        
        ctr = ctr+1;
    
    
    
    end
end

out_month = ts_make(out,12,year0(1)*100+1);
