function [y_kern,y_norm,x_values]=abs_dist_plot(n,T)

X=zeros(T,1);
for j=1:T
    draw_vec=randn(n,1);
    [Y,I]=max(abs(draw_vec));
     X(j)=draw_vec(I);
end
% hist(X,50)
pd=fitdist(X,'kernel');

x_values = -5:0.05:5;

y_kern = pdf(pd,x_values);
% plot(x_values,y_kern,'LineWidth',2)
hold on
mu = 0;
sigma = 1;
pd_normal = makedist('Normal','mu',mu,'sigma',sigma);
y_norm = pdf(pd_normal,x_values);
% plot(x_values,y,'LineWidth',2)
