%% Make the nu-de picture
load ../output_files/model_solution all nu_grid out*

load ../output_files/gdp_hrs_中国年度.mat
idx_base = find(nu_grid==1);

suff = 'eps';
form = 'epsc';

suff = 'pdf';
form = 'pdf';

load template
load template1x2

template.PaperPosition = [-0.5000 0 13.5000 5.5000];
template.PaperSize     = [12.5,5.5];
%% FIGURE 11: 2x2 figure showing how NU matters

var_rat_sm = zeros(size(all));
var_rat_sml= zeros(size(all));
stdy2      = zeros(size(all));
stdy       = zeros(size(all));
stdl       = zeros(size(all));
stdk       = zeros(size(all));
rfrac      = zeros(size(all));
for jj = 1:size(all,2)
    
%     var_rat_sm(1,jj) = 1 - var(all{1,jj}.gdp_fit(:))./var(all{1,jj}.gdp(:));  
%     var_rat_sml(1,jj) = 1 - var(all{1,jj}.hrs_fit(:))./var(all{1,jj}.hrs(:));
%     
    
    var_rat_sm(1,jj)  = 1 - all{1,jj}.var_rat;
    var_rat_sml(1,jj) = 1 - all{1,jj}.var_rat_ll;

    stdy(1,jj)   = std(diff(all{1,jj}.cc(:)));
    stdl(1,jj)   = std(diff(all{1,jj}.ll(:)));
    rfrac(1,jj) = all{1,jj}.gdp_resid(3)/all{1,jj}.gdp(3);
end

f = figure;
fs = 14;

s = subplot(2,2,1);
plot(nu_grid,stdy', 'linewidth',2); hold on;
plot([0,nu_grid(2:end)],.016 + 0*nu_grid, ':k', 'linewidth', 1.5)
ylabel('std$(\Delta c_t)$','interpreter', 'latex','FontSize',fs);
xlabel('Labor supply elasticity ($\nu)$','interpreter','latex','FontSize',fs);
s.XLim = [0,max(nu_grid)];
%s.YLim = [0,0.05];
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;


s = subplot(2,2,2);
plot(nu_grid,stdl', 'linewidth',2); hold on;
plot([0,nu_grid(2:end)],.023 + 0*nu_grid, ':k', 'linewidth', 1.5)
ylabel('std$(\Delta l_t)$','interpreter', 'latex','FontSize',fs);
xlabel('Labor supply elasticity ($\nu)$','interpreter','latex','FontSize',fs);
s.XLim = [0,max(nu_grid)];
%s.YLim = [0,0.05];
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;

s = subplot(2,2,3);
plot(nu_grid,var_rat_sm', 'linewidth',2);hold on;
plot([0,nu_grid(2:end)],0.2 + 0*nu_grid, ':k', 'linewidth', 1.5)
ylabel('var$\left(\epsilon_t^c\right)/$var$\left(c_t\right)$', 'interpreter', 'latex','FontSize',fs);
xlabel('Labor supply elasticity ($\nu)$','interpreter','latex','FontSize',fs);
s.XLim = [0,max(nu_grid)];
%s.YLim = [0.00, 0.45];
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;

s = subplot(2,2,4);
plot(nu_grid,var_rat_sml', 'linewidth',2);hold on;
%plot(nu_grid,0.2 + 0*nu_grid, ':k', 'linewidth', 2)
ylabel('var$\left(\epsilon_t^l\right)/$var$\left(l_t\right)$', 'interpreter', 'latex','FontSize',fs);
xlabel('Labor supply elasticity ($\nu)$','interpreter','latex','FontSize',fs);
s.XLim = [0,max(nu_grid)];
%s.YLim = [0.00, 0.45];
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;

setprinttemplate(f,template)
f.Units = 'inches';
f.Position = [0 0 9 7];
f.PaperSize =   [ 9.5000    6.0000];
f.PaperPosition = [   -0.7000         0   11.0000    6.000]
saveas(f, ['../output_files/figure15.',suff], form);

%% FIGURE 11 - Compure output histories across model versions
a = all{idx_base};
f = figure; 

s = subplot(1,2,1);
plot(a.dates,a.gdp,'linewidth',2);
hold on;
plot(a.dates,a.gdp_nn,'-.','linewidth',2 );
plot(a.dates,a.gdp_full, ':k','linewidth',2);
s.XLim = [min(a.dates),max(a.dates)];
xlabel('Year', 'interpreter', 'latex', 'FontSize', fs);
ylabel('Output ($c_t$)', 'interpreter', 'latex', 'FontSize', fs);
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;

s = subplot(1,2,2);
plot(a.dates,a.hrs,'linewidth',2);
hold on;
plot(a.dates,a.hrs_nn,'-.','linewidth',2);
plot(a.dates,a.hrs_full, ':k','linewidth',2);
s.XLim = [min(a.dates),max(a.dates)];
legend('Baseline model', 'No news media', 'Full information.','Location','southwest');
xlabel('Year', 'interpreter', 'latex', 'FontSize', fs);
ylabel('Labor ($l_t$)', 'interpreter', 'latex', 'FontSize', fs);
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;

f.PaperOrientation = 'landscape';

f.Units = 'inches';
f.Position = [0 0 12 5];
setprinttemplate(f,template1x2)
saveas(f, ['../output_files/figure11.',suff], form);

%% FIGURE 12: Cross section in 2009

load ../output_files/tfp
load ../output_files/omega



tfp=detrend(log(tfp(21:end,:)));
finance_tfp_2009=tfp(3,:);
finance_tfp_2009([1:8 10:end])=NaN;
f = figure;
s = subplot(1,2,1); 
bar(tfp(3,:))
hold on
bar(finance_tfp_2009,'r'); 
% text( 13,-0.13,'Motor Vehicles'); annotation('textarrow',[.33,.35], [.19,.23])
% text( 26,-0.05,'F.I.R.E.'); annotation('textarrow',[.44,.44], [.45,.53])
% text( 11,.093,'Instruments'); annotation('textarrow',[.29,.365], [.89,.86])
% text( 22.5,.093,'Misc. manufacturing'); annotation('textarrow',[.42,.39], [.9,.8])
% text( 1,.081,'Oil and gas extraction'); annotation('textarrow',[.165,.165], [.84,.8])

xlabel('Sectors numbered as in Table I', 'interpreter', 'latex', 'FontSize', fs);
ylabel('Sectoral productivity in 2009, log-deviation from trend',  'interpreter', 'latex', 'FontSize', fs);

%s.YLim = [-.15,+.105]
grid on;
subplot(1,2,2);
bar(abs(omega_opt.*tfp(3,:)'));
hold on
bar(abs(omega_opt.*finance_tfp_2009'),'r')
xlabel('Sectors numbered as in Table I', 'interpreter', 'latex', 'FontSize', fs);
ylabel('Relative newsworthiness in 2009',  'interpreter', 'latex', 'FontSize', fs);
grid on;

setprinttemplate(f,template1x2)
saveas(f, ['../output_files/figure12.',suff], form);


%% FIGURE 13 - Compare to actual history
a = all{idx_base};
f = figure; 

s = subplot(1,2,1);
plot(a.dates(1:end-1),demean(diff(a.gdp(1:end)')),'linewidth',2);
hold on;
plot(a.dates(1:end-1),demean(diff(gdp_a(1:end-1))),'-.k','linewidth',2,'color',[0.35 0.35 0.35]);
s.XLim = [min(a.dates),max(a.dates)];
xlabel('Year', 'interpreter', 'latex', 'FontSize', fs);
ylabel('Output ($c_t$)', 'interpreter', 'latex', 'FontSize', fs);
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;
 
s = subplot(1,2,2);
plot(a.dates(2:end),demean(diff(a.hrs(1:end)')),'linewidth',2);
hold on;
plot(a.dates(2:end),demean(diff(hrs_a(1:end-1))),'-.k','linewidth',2,'color',[0.35 0.35 0.35]);
s.XLim = [min(a.dates),max(a.dates)];
legend('Baseline model', 'Actual growth','Location','southwest');
xlabel('Year', 'interpreter', 'latex', 'FontSize', fs);
ylabel('Labor ($l_t$)', 'interpreter', 'latex', 'FontSize', fs);
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;
f.PaperOrientation = 'landscape';

f.Units = 'inches';
f.Position = [0 0 12 5];
setprinttemplate(f,template1x2)
saveas(f, ['../output_files/figure13.',suff], form);

%% FIGURE 14 - Projection figure
a = all{idx_base};
f = figure; 

s = subplot(1,2,1);
plot(a.dates,a.gdp,'linewidth',2);
hold on;
plot(a.dates,a.gdp_fit,':','linewidth',2, 'color',[70/255 145/255 105/255] );
plot(a.dates,a.gdp_resid, '-.','linewidth',2, 'color', [90/255 90/255 90/255]);
s.XLim = [min(a.dates),max(a.dates)];
xlabel('Year', 'interpreter', 'latex', 'FontSize', fs);
ylabel('Output ($c_t$)', 'interpreter', 'latex', 'FontSize', fs);
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;
 
s = subplot(1,2,2);
plot(a.dates,a.hrs,'linewidth',2);
hold on;
plot(a.dates,a.hrs_fit,':','linewidth',2,'color',[70/255 145/255 105/255]);
plot(a.dates,a.hrs_resid, '-.','linewidth',2,'color',[90/255 90/255 90/255] );
s.XLim = [min(a.dates),max(a.dates)];
legend('Baseline model', 'Projected onto sectoral TFP', 'Residual','Location','southwest');
xlabel('Year', 'interpreter', 'latex', 'FontSize', fs);
ylabel('Labor ($l_t$)', 'interpreter', 'latex', 'FontSize', fs);
grid on
s.GridLineStyle = ':';
s.GridAlpha = .4;
%f.PaperOrientation = 'landscape';

%f.Units = 'inches';
%f.Position = [0 0 12 5];
setprinttemplate(f,template1x2)
saveas(f, ['../output_files/figure14.',suff], form);

%% Number reported in the paper
disp(' ')
disp('Numbers reported in text:')
load ../output_files/tfp
tfp     = detrend(tfp);
corr_tfp = (tril(corr(tfp),-1));

a = all{idx_base};

corl   = tril(a.corl,-1);
corlnn = tril(a.corlnn,-1);a

disp('Section 6.1:')
disp(['Avg cross-sect corr of TFP        : ' num2str(mean(corr_tfp(corr_tfp(:)~=0)), '%0.2f')]);

disp(' ');
disp('Section 6.3:')
disp(['Std of output          Base|NoNews: ' num2str(100*[std(a.cc),std(a.ccnn)], '%1.1f|')])
disp(['Std of hours           Base|NoNews: ' num2str(100*[std(a.ll),std(a.llnn)], '%1.1f|')])
disp(['Avg. cross-sect corr L Base|NoNews: ' num2str([mean(corl(corl(:)~=0)),mean(corlnn(corlnn(:)~=0))], '%0.2f|')]);

disp(' ');
disp('Section 6.4:')
disp(['GDP gap, 2009 Base|NoNews     : '  num2str(100*[a.gdp(3), a.gdp_nn(3)],'%1.1f|')])
disp(['HRS gap, 2009 Base|NoNews     : '  num2str(100*[a.hrs(3), a.hrs_nn(3)],'%1.1f|')])

disp(' ');
disp('Section 6.5')
disp(['GDP gap, 2009 Base|Full       : '  num2str(100*[a.gdp(3), a.gdp_full(3)],'%1.1f|')])
disp(['HRS gap, 2009 Base|Full       : '  num2str(100*[a.hrs(3), a.hrs_full(3)],'%1.1f|')])

disp(' ');
disp('Section 6.6:')
disp(['Actual 2009 growth GDP|Hrs    : ' num2str(100*[min(demean(diff(gdp_a))),min(demean(diff(hrs_a)))], '%1.1f|')]);
disp(['GDP growth corr  Base|Full    : ' num2str([corr(a.dgdp(:),diff(gdp_a(2:end))),corr(a.dgdp_full(:),diff(gdp_a(2:end)))], '%0.2f|')])
disp(['HRS growth corr  Base|Full    : ' num2str([corr(diff(a.hrs(:)),diff(hrs_a(2:end))) corr(diff(a.hrs_full(:)),diff(hrs_a(2:end)))], '%0.2f|')])

disp(' ')
disp('Section 6.7:');
disp(['Atalay share       GDP|Hrs    : '  num2str(100*[(1-a.var_rat),(1-a.var_rat_ll)], '%2.0f|')])

disp(' ')
disp('Section 6.8:')
disp(['Std(GDP)randnews|nowghts|nostdp: ' num2str(100*[std(out_randnews.cc),std(out_nowghts.cc),std(out_nocond.cc)], '%1.1f|')])


% disp('2009 Fracs: Cons|Labor')
% [all{1,idx_base}.gdp_resid(23)/all{1,idx_base}.gdp(23),all{1,idx_base}.hrs_resid(23)/all{1,idx_base}.hrs(23)]
