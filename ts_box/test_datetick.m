 t = (1900:10:1990)'; % Time interval
       p = [75.995 91.972 105.711 123.203 131.669 ...
           150.697 179.323 203.212 226.505 249.633]';  % Population
       plot(datenum(t,1,1),p) % Convert years to date numbers and plot
       datetick('x','mmmyyyy') % Replace x-axis ticks with 4 digit year labels.
     
