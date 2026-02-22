%Plotting figures for Sectoral Media Focus
clear all
n_small=30;
n_large=80;

fs = 14;
suff = 'pdf';
form = 'pdf';
%% Create figure
T=100000;
[y_kern_small,y_norm,x_values]=abs_dist_plot(n_small,T);
[y_kern_large,y_norm,x_values]=abs_dist_plot(n_large,T);

f = figure;
s = subplot(1,1,1);
plot(x_values,y_norm,'linewidth',2);
hold on
plot(x_values,y_kern_small,'linewidth',2,'linestyle','--');
hold on
plot(x_values,y_kern_large,'linewidth',2,'linestyle',':');
legend('p(z_i)',strcat('p(z_i|s_i = 1), n=',num2str(n_small)) ,strcat('p(z_i|s_i = 1), n=', num2str(n_large))); 
xlabel('$z_i$', 'interpreter','latex', 'fontsize',fs);
ylabel('Density', 'interpreter','latex', 'fontsize',fs);
s.YTickLabel = [];
% grid on;
s.Box = 'on';
s.GridLineStyle = ':';
s.GridAlpha = .4;

f.Units = 'inches';
f.Position = [0 0 9 8];
f.PaperSize =   .85*[ 9.60000    6.5000];;
f.PaperPosition = .85*[   -1.000         -.1  11.5000    7.000]
saveas(f, ['../output_files/figure2.',suff], form);


%% %%%%%%%%%%%%%%
f = figure;
s = subplot(1,1,1);
x_min=-4;
step_size=0.001;
x_max=4;
X1=x_min:step_size:x_max;
Y1=[];
for j=x_min:step_size:x_max
    Y1=[Y1 normpdf(j,0,1)];    
end

yvector1=(X1>1.5 | X1<-1.5 ).*Y1;
plot(X1,Y1,'LineWidth',2);
hold on;
a = area(X1,yvector1,'FaceColor',[0.00,0.45,0.74],...
    'LineStyle','none');
 a.FaceAlpha = .5;
legend('p(z_j)','p(z_j|z_i,s_i=1,s_j=0)=0');

axis([min(X1) max(X1) min(Y1) max(Y1)*1.2])
%title({'Distribution of non-reported productivity shocks'});
xlabel('$z_j$', 'interpreter','latex', 'fontsize',fs);
ylabel('Density', 'interpreter','latex', 'fontsize',fs);

xticks([-4 -3 -2 -1.5 -1 0 1 1.5 2 3 4]);
xticklabels({'-4','-3','-2','|z''_i|','-1','0','1','|z''_i|','2','3','4'});



s.YTickLabel = [];
% grid on;
s.Box = 'on';
s.GridLineStyle = ':';
s.GridAlpha = .4;

f.Units = 'inches';
f.Position = [0 0 9 8];
f.PaperSize =   .85*[ 9.60000    6.5000];
f.PaperPosition = .85*[   -1.000         -.1  11.5000    7.000];

saveas(f, ['../output_files/figure3.',suff], form);


%% %%%%%%%%%%%%%%%%%
f = figure;
s = subplot(1,1,1);
[y_kern_small,y_norm,x_values]=min_dist_plot(n_small,T);
[y_kern_large,y_norm,x_values]=min_dist_plot(n_large,T);
plot(x_values,y_norm,'linewidth',2);
hold on
plot(x_values,y_kern_small,'linewidth',2,'linestyle','--');
hold on
plot(x_values,y_kern_large,'linewidth',2,'linestyle',':');
legend('p(z_i)',strcat('p(z_i|s_i = 1), n=',num2str(n_small)) ,strcat('p(z_i|s_i = 1), n=', num2str(n_large))); 
xlabel('$z_i$', 'interpreter','latex', 'fontsize',fs);
ylabel('Density', 'interpreter','latex', 'fontsize',fs);

s.YTickLabel = [];
% grid on;
s.Box = 'on';
s.GridLineStyle = ':';
s.GridAlpha = .4;

f.Units = 'inches';
f.Position = [0 0 9 8];
f.PaperSize =   .85*[ 9.60000    6.5000];
f.PaperPosition = .85*[   -1.000         -.1  11.5000    7.000];

saveas(f, ['../output_files/figure4.',suff], form);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure;
s = subplot(1,1,1);


yvector2=(X1<-1.5 ).*Y1;
plot(X1,Y1,'LineWidth',2);
hold on;
a = area(X1,yvector2,'FaceColor',[0.00,0.45,0.74],...
     'LineStyle','none');
 a.FaceAlpha = .5;
 legend('p(z_j)','p(z_j|z_i,s_i=1,s_j=0)=0');
axis([min(X1) max(X1) min(Y1) max(Y1)*1.2])
xticks([-4 -3 -2 -1.5 -1 0 1 2 3 4]);
xticklabels({'-4','-3','-2','z''_i','-1','0','1','2','3','4'});
%title({'Distribution of non-reported productivity shocks'});
xlabel('$z_j$', 'interpreter','latex', 'fontsize',fs);
ylabel('Density', 'interpreter','latex', 'fontsize',fs);


s.YTickLabel = [];
% grid on;
s.Box = 'on';
s.GridLineStyle = ':';
s.GridAlpha = .4;

f.Units = 'inches';
f.Position = [0 0 9 8];
f.PaperSize =   .85*[ 9.60000    6.5000];
f.PaperPosition = .85*[   -1.000         -.1  11.5000    7.000];

saveas(f, ['../output_files/figure5.',suff], form);
