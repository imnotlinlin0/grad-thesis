function [y_kern,y_norm,x_values]=min_dist_plot(n,T)

X=zeros(T,1);
for j=1:T
     X(j)=min(randn(n,1));
end
% hist(X,50)
pd=fitdist(X,'kernel');

% figure
x_values = -5:0.05:5;

y_kern = pdf(pd,x_values);
% plot(x_values,y_kern,'LineWidth',2)
hold on
mu = 0;
sigma = 1;
pd_normal = makedist('Normal','mu',mu,'sigma',sigma);
y_norm = pdf(pd_normal,x_values);
% plot(x_values,y,'LineWidth',2)
