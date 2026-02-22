%ts_plot


function ts_plot(ts)


t = size(ts.dat);
c_date = ts.sd;
for j = 1:t
    date_str = num2str(c_date);
    c_date = MQ_index(c_date,1,ts.freq);
    disp([date_str, '     ', num2str(ts.dat(j,:), '%.2f \t')]);
end