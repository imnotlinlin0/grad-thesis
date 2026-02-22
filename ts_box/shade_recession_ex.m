dat = 1:10;
r = [ 0 0 0 1 1 1 0 0 0 1];
s = subplot(1,1,1)
plot(dat)
shade_recession(s,r)
