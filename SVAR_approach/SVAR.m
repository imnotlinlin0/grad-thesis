% Estimate SVAR(4) using Metropolis-Hastings
clc
clear all
%close all

%set control parameters of code
n=2;%number of variales in VAR
p=2;%nuber of lags in VAR
J=1e7;%Number of draws/size of MCMC
S=1e5;%Number of independent draws from MCMC for figures
rng(0)

load ../output_files/var_data


%Z=[nce_rgdp_3'; d_rgdp_3';];
Z = var_data';

Z_news=dev_emp_wn';
Z_raw=Z;

Z1=Z(:,1:end-2);
Z2=Z(:,2:end-1);
%Z3=Z(:,2:end-3);
%Z4=Z(:,1:end-4);
Z=[Z1;Z2;];
Y=Z_raw(:,3:end);
Z=Z-mean(Z,2);
Y=Y-mean(Y,2);
T=max(size(Z));
%%
%Use OLS starting values for MCMC
A_ols= Y*Z'/(Z*Z');
theta_A=A_ols(:);
resid=Y-A_ols*Z;
diag_omega=diag(cov(resid'));
C=diag(diag_omega.^.5);
theta_C=C(:);
theta=[theta_C;theta_A]; %Starting value for parameter vector

%impose sign restrictions boundaries of as uniform prior densities
LB_C=[0,0,-inf,0;];
UB_C=[inf,inf,0,inf;];

% Set control parameters of MH define needed objects
epseye=1e-5;%initial scaling of proposal distribution covariance matrix
lpostdraw = -9e+200;%Set up so that the first candidate draw is always accepted
bdraw=theta;%mean of first draw
vscale=diag(abs(theta))*epseye+1e-8*eye(length(theta)); %variance of first draw

%Store all draws in MCMC
MCMC=zeros(length(theta),J);
MCMC(:,1)=theta;
%Keep track of switches and drwas outside LB and UB
OutsideProp=zeros(J,1);
SwitchesProp=zeros(J,1);
%Number of draws outside parameter boundaries
q=0;
%Number of switches (acceptances)
pswitch=0;
%Iteration counter
iter=0;

%--------------------------------------------------------------------------
% MH algorithm starts here
%--------------------------------------------------------------------------
tic
for iter=1:J
    
    % Draw from proposal density Theta*_{t+1} ~ N(Theta_{t},vscale)
    bcan = bdraw + norm_rnd(vscale);
    
    if min(bcan(1:4) >= LB_C')==1 %impose sign restrictions
        if min(bcan(1:4) <= UB_C')==1 %impose sign restrictions
            
            lpostcan = LLVAR(bcan,Y,Z,n,p);%returns log-likelihood of Y=BZ+e where Y is nxT and Z is (nxp)xT
            laccprob = lpostcan-lpostdraw;%compute acceptance probability of candidate draw
        else
            laccprob=-9e+200;
            q=q+1;
        end
    else
        laccprob=-9e+200;
        q=q+1;
    end
    
    %Accept candidate draw with log prob = laccprob, else keep old draw
    if log(rand)<laccprob
        lpostdraw=lpostcan;
        bdraw=bcan;
        pswitch=pswitch+1;
    end
    
    MCMC(:,iter)=bdraw;%save current draw
    
    OutsideProp(iter)=q/iter;
    SwitchesProp(iter)=pswitch/iter;
    
    %use adaptive propsoal density
    if iter >= 1000 && mod(iter,20000)==0
        vscale=2e-1*cov(MCMC(:,1:100:iter)');
        disp(num2str(iter))
        
    end
    
end
toc
MCMC=MCMC(:,J*.5:end);
disp(['iter: ',num2str(iter)]);
disp(['acceptance rate: ',num2str(SwitchesProp(iter))]);


%%

%Define objects needed for figures

periods=20;%periods for IRFs
ra = J/2;
ff = ceil(ra.*rand(S,1)); %contains indices of S independent draws from MCMC

%construct matrices to store output in
RR=zeros(2,T,S);
SS=zeros(2,T,S);
corr_emp_news_b=zeros(1,S);
corr_emp_news_n=zeros(1,S);

corr_stk_news_b=zeros(1,S);
corr_stk_news_n=zeros(1,S);
IMPR=zeros(n,n,periods,S);

% CC=zeros(8,2);
CC=zeros(4,2);
for s=1:S
    %objects needed for IRFs
    C_draw=reshape(MCMC(1:4,ff(s)),2,2);
    A_draw=reshape(MCMC(5:end,ff(s)),2,4);
    
    % AA=[A_draw;
    % eye(2),zeros(2,2);
    % zeros(2,2),eye(2);];
    % AA = [A_draw, eye(2);, zeros(2,2)];
    AA = [A_draw; eye(2), zeros(2,2)];
    
    CC(1:2,:)=C_draw;
    
    
    %objects needed for correlation histograms
    RR(:,:,s) = Y - A_draw*Z;
    SS(:,:,s) = C_draw\RR(:,:,s);
    
    
    %compute IRFs
    AAss = eye(size(AA));%
    for ss=0:periods-1

        % IMPR(:,1,ss+1,s)= [eye(2),zeros(2,6)]*(AAss)*CC(:,1);
        % IMPR(:,2,ss+1,s)= [eye(2),zeros(2,6)]*(AAss)*CC(:,2);
        IMPR(:,1,ss+1,s)= [eye(2),zeros(2,2)]*(AAss)*CC(:,1);
        IMPR(:,2,ss+1,s)= [eye(2),zeros(2,2)]*(AAss)*CC(:,2);
        % IMPR(:,1,ss+1,s)= [eye(2),zeros(2,2)] * AAss * [CC(:,1); zeros(2,1)];% 补充zeros(2,1)使CC变为4×1，匹配4×4的AAss
        % IMPR(:,2,ss+1,s)= [eye(2),zeros(2,2)] * AAss * [CC(:,2); zeros(2,1)];% 同上
        AAss = AAss*AA;
    end
    
    %compute correlations
    corr_emp_news_b(s)=corr(Z_news(1:end-1)',SS(2,:,s)');
    corr_emp_news_n(s)=corr(Z_news(1:end-1)',SS(1,:,s)');
    
end
Impsort11=reshape(sort(IMPR(1,1,:,:),4),periods,S);
Impsort12=reshape(sort(IMPR(1,2,:,:),4),periods,S);
Impsort21=reshape(sort(IMPR(2,1,:,:),4),periods,S);
Impsort22=reshape(sort(IMPR(2,2,:,:),4),periods,S);

save ../output_files/svar_output Impsort* corr_emp_news* dev_emp_w* SS* periods S
