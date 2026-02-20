function [d_mean_news,Sind]=d_mean_news(omega,zz,mean_sector_news)

N = size(zz,1);

[~, SS]=max(abs(diag(omega)*(zz)));

Sind = sum(SS==(1:N)',2);
Sind = Sind./sum(Sind);

d_mean_news = sum((Sind - mean_sector_news).^2).^.5;


%[Sind,mean_sector_news]



