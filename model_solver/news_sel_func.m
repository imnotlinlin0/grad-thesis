function [zz_s,SS]=news_sel_func(zz,nsf,lambda,mu_z)

if nsf==1
[zz_s_dev, SS]=max(abs(zz-mu_z));
zz_s= zz_s_dev + mu_z;
end


if nsf==2
[~, SS]=max(abs(diag(lambda)*(zz-mu_z)));
zz_s=zz(:,SS);
end