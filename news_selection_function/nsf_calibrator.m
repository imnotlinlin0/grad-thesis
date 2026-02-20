% NSF_calibrator:
%
% Calibrate the OMEGA matrix of unconditional news weights to match the
% frequency of each sector appearing in the news data.
%
% NOTE: This step takes about 40 minutes on a iMac desktop computer.

N = 11;      %Number of sectors
T = 11; %Number of periods

rseed = 0;
eyescale = eye(N)*1e-8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct matrix zz with sectoral tfp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = xlsread("D:\摸鱼\毕业论文\毕业论文\code\output_files\news_fractions_baseline_filtered_ANNUAL_MEANS.xlsx");

mean_sector_news = mean(a(:,2:end))';

load ../output_files/tfp tfp
tfp=tfp(21:end,:);
tfp     = detrend(log(tfp))';  %Transpose so Rows = sectors
mu_z    = mean(tfp,2);
cov_tfp = cov(tfp')+eyescale;
chol_tfp= chol(cov_tfp);

%construct and save random draws
s = RandStream('mt19937ar','seed',0);
shocks=chol_tfp'*randn(s,N,T);

zz = mu_z + shocks;


%Starting value
omega_st=ones(N,1)./N;

%Bounds
LB=zeros(N,1);
UB=ones(N,1);

% Simulated annealing to find best match actual news data x=THETA;
sa_t= 10;
sa_rt=.95;
sa_nt=50;
sa_ns=50;
tic
[omega_opt]=simannb(@(x) d_mean_news(x,zz, mean_sector_news), omega_st, LB, UB, sa_t, sa_rt, sa_nt, sa_ns, 1);
toc


save ../output_files/omega omega_opt
