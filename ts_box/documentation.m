% Examples using a number of my favorite ts_box functions




%Sampel Series
dat = exp(randn(100,1));
sample_ts = ts_make(dat,4,195401, 'Series Name (Optional)');  %Quarterly, Starting in 1954:Q1

dat = exp(randn(400,1));
sample_ts2 = ts_make(dat,12,193601, 'Series Name 2 (Optional)'); %Monthly, Stating in 1936:Jan


%Plot the NBER series
ts_plot(sample_ts);
ts_plot(sample_ts2);

%Convert ts2 to quarterly
sample_ts3 = M2Q(sample_ts2);

%Plot two series at once, setting the upper and lower bounds on the y-axis
ts_plot(sample_ts, sample_ts3, [0, 5; -1, 9]);

%Print the variable(s) to the screen
ts_print(sample_ts, sample_ts3);

%Print the TS to an comma_delimited file
ts_out('sample_ts.xls', sample_ts);

%Get a subset of the ts_series data, transformed in a particular way
vect(sample_ts, 0,'log-chg',[195404, 197001])
