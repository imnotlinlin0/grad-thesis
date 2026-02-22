function x = ts_fill(x,date_range)

sd = x.sd;
ed = x.ed;
freq = x.freq;

sd_n = date_range(1);
ed_n = date_range(2);


%How many periods to add at start
n = 0;
while sd_n<sd
    n = n+1;
    sd_n = MQ_index(sd_n, 1, freq);
end

p = 0;
while ed<ed_n
   p = p+1;
   ed = MQ_index(ed,1,freq); 
end

x.dat = [NaN(1,n),x.dat(:)',NaN(1,p)];

if n > 0
    x.sd = date_range(1) ;
end

if p > 0 
    x.ed = date_range(2);
end
    
