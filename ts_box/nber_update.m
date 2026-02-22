url = 'https://fred.stlouisfed.org/';
c = fred(url);

nber = fetch(c,'USRECD');  

NBER = D2M_Fred(nber.Data);

save NBER_rec NBER