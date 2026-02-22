load template1x2
template.PaperPosition = [-0.5000 0 13.5000 5.5000];
template.PaperSize     = [12.5,5.5];

load ../output_files/svar_output

suff = 'pdf';
form = 'pdf';
%define plotted percentiles of posterior
med=0.5;
top=0.975;
top16=0.84;
bot16=0.16;
bot=.025;

%% MAKE_FIGURES - for Section 7 of the paper

%% TIMESERIES
fs = 14;
dates=[2007:2017]';

SS_f=reshape(SS(1,:,:),10,S);
SS_b=reshape(SS(2,:,:),10,S);

f = figure;
s0 = subplot(3,1,1);
plot(dates,dev_emp_wn,'linewidth',1.5, 'color','k')
hold on
plot(dates,dev_emp_w,'linewidth',1.5,'linestyle','-.', 'color',[0 0.4470 0.7410]);
axis([min(dates) max(dates) -.1 .1]);
s0.YTick = [-.1:.05:.1];
ylabel('$\Delta l_t^{unrep}$','interpreter', 'latex','FontSize',fs);
xlabel('Year','interpreter', 'latex','FontSize',fs)
legend('Baseline', 'Not scaled by News Heard Index')


grid on
s0.GridLineStyle = ':';
s0.GridAlpha = .4;

s0 = subplot(3,1,2);
% s = shade(dates,.01*prctile(SS_f,97.5,2),dates,.01*prctile(SS_f,2.5,2),'FillType',[1 2]);
%s = shade(dates, .01*prctile(SS_f,97.5,2)(:), dates, .01*prctile(SS_f,2.5,2)(:), 'FillType', [1 2]);
% 第二个子图修正代码
ss_f_975 = .01 * prctile(SS_f,97.5,2);
ss_f_25 = .01 * prctile(SS_f,2.5,2);
s = shade(dates(1:end-1), ss_f_975(:), dates(1:end-1), ss_f_25(:), 'FillType', [1 2]);
s(1).Visible = 'off';
s(2).Visible = 'off';
s(3).FaceColor = [0.34,0.71,0.98];
hold on
%plot(dates,prctile(SS_f,97.5,2),'color','k','linewidth',0.5);
hold on
%plot(dates,prctile(SS_f,2.5,2),'color','k','linewidth',0.5);
% hold on;
plot(dates(1:end-1),.01*prctile(SS_f,50,2),'color','k','linewidth',1);
ylabel('$u_t^f$','interpreter', 'latex','FontSize',fs);
xlabel('Year','interpreter', 'latex','FontSize',fs)
axis([min(dates(1:end-1)) max(dates(1:end-1)) -0.03 0.03])
s0.YTick = [-0.03:.01:0.03];

grid on
s0.GridLineStyle = ':';
s0.GridAlpha = .4;

s0 = subplot(3,1,3);
% s = shade(dates,.01*prctile(SS_b,97.5,2),dates,.01*prctile(SS_b,2.5,2),'FillType',[1 2]);
s = shade(dates(1:end-1), .01*prctile(SS_b,97.5,2), dates(1:end-1), .01*prctile(SS_b,2.5,2), 'FillType', [1 2]);
s(1).Visible = 'off';
s(2).Visible = 'off';
s(3).FaceColor = [0.34,0.71,0.98];
hold on
%plot(dates,prctile(SS_b,97.5,2),'color','k','linewidth',0.5);
hold on
%plot(dates,prctile(SS_b,2.5,2),'color','k','linewidth',0.5);
hold on;
plot(dates(1:end-1),.01*prctile(SS_b,50,2),'color','k','linewidth',1);
ylabel('$u_t^b$','interpreter', 'latex','FontSize',fs)
xlabel('Year','interpreter', 'latex','FontSize',fs)
axis([min(dates(1:end-1)) max(dates(1:end-1)) -.03 .03])
s0.YTick = [-0.03:.01:0.03];

grid on
s0.GridLineStyle = ':';
s0.GridAlpha = .4;

%setprinttemplate(f,template)
f.Units = 'inches';
f.Position = [0 0 9 8];
f.PaperSize =   [ 8.5000    7.10000];
f.PaperPosition = [   -0.6000         -.4  10.0000    8.000]
saveas(f, ['../output_files/figure16.',suff], form);




%% IRFs
f = figure;
fs = 14;

%plot IRFs
x=[1:1:periods];
s0 = subplot(1,2,1); s0.Box = 'on';
hold on;
s = shade(x,Impsort21(:,S*top),x,Impsort21(:,S*bot),'FillType',[1 2]);
s(1).Visible = 'off';
s(2).Visible = 'off';
s(3).FaceColor = [0.34,0.71,0.98];
hold on;
plot(Impsort21(:,S*med),'color','black','LineWidth',2);
xlabel('Response to fundamental shock','interpreter', 'latex','FontSize',fs)
ylabel('$100\times\Delta y_t$','interpreter', 'latex','FontSize',fs)
axis([min(x) max(x) -300 300])

grid on
s0.GridLineStyle = ':';
s0.GridAlpha = .4;

s0 = subplot(1,2,2); s0.Box = 'on';

hold on;
s = shade(x,Impsort22(:,S*top),x,Impsort22(:,S*bot),'FillType',[1 2]);
s(1).Visible = 'off';
s(2).Visible = 'off';
s(3).FaceColor = [0.34,0.71,0.98];
hold on;
plot(Impsort22(:,S*med),'color','black','LineWidth',2);
xlabel('Response to belief shock','interpreter', 'latex','FontSize',fs)
ylabel('$100\times\Delta y_t$','interpreter', 'latex','FontSize',fs)
axis([min(x) max(x) -300 300])

grid on
s0.GridLineStyle = ':';
s0.GridAlpha = .4;

setprinttemplate(f,template1x2)
%setprinttemplate(f,template)
f.Units = 'inches';
% f.Position = [0 0 9 8];
% f.PaperSize =   [ 8.5000    7.10000];
% f.PaperPosition = [   -0.9000         -.4  10.0000    6.000]
saveas(f, ['../output_files/figure17.',suff], form);

%% Correlation Density
%plot psoterior distribution of correlations
f = figure;
s0 = subplot(1,2,1);
h = histogram(corr_emp_news_n,50);
h.EdgeAlpha = 0;
axis([-1 1 0 4500])
%title('Fundamental shocks','fontsize',16)
xlabel('corr($u_t^f$ , $\Delta l_t^{dev}$)','interpreter', 'latex','FontSize',fs);
grid on
s0.GridLineStyle = ':';
s0.GridAlpha = .4;
s0.YTickLabel = [];
s0.XTick = [-1,-.5,0,.5,1];
ylabel('Density','interpreter', 'latex','FontSize',fs);

s0 = subplot(1,2,2);
h = histogram(corr_emp_news_b,50);
h.EdgeAlpha = 0;
axis([-1 1 0 4500])
%title('Belief shocks','fontsize',16)
xlabel('corr($u_t^b$ , $\Delta l_t^{dev}$)','interpreter', 'latex','FontSize',fs)
grid on
s0.GridLineStyle = ':';
s0.GridAlpha = .4;
s0.YTickLabel = [];
% s0.XTick = [-.5,-.25,0,.25,.5];
s0.XTick = [-1,-.5,0,.5,1];
ylabel('Density','interpreter', 'latex','FontSize',fs);

setprinttemplate(f,template1x2)
f.Units = 'inches';
saveas(f, ['../output_files/figure18.',suff], form);



disp("median(corr_emp_news_n)=");
disp(median(corr_emp_news_n))
disp("median(corr_emp_news_b)=");
disp(median(corr_emp_news_b))
disp("percentile(corr_emp_news_n(:),.025)=")
disp(percentile(corr_emp_news_n(:),.025))