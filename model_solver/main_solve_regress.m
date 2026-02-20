% Code to solve benchmark model in Chahrour, Nimark and Pitschner

function a = main_solve_regress(nu, varargin)

%Random News
if length(varargin)>0 && strcmp(varargin{1}, 'rnd')
    rand_news = true;
else
    rand_news = false;
end

%No weights in news
if length(varargin)>0 && strcmp(varargin{1}, 'nwt')
    nwt = true;
else
    nwt = false;
end
    
%No conditioning non-reported sectors
if length(varargin)>0 && strcmp(varargin{1}, 'ncnd')
    ncnd = true;
else
    ncnd = false;
end


tic0  = tic;
relax = min(nu,1);

% Length of simulation
S    = 100*1000;

%% **************************************************************************
% Load input data
%**************************************************************************

%Load news weights (omega)
load ../output_files/omega omega_opt

%Load TFP data
load ../output_files/tfp tfp
tfp=tfp(21:31,:);

%Load IO structure
load ../output_files/IO11 A alph_sec alphk_sec bet

%**************************************************************************
% Compute objects related to IO structure
%**************************************************************************
bet(bet<=0)=0.0001;
bet=bet/sum(bet);

N      = size(A,1);
I      = eye(N);
lgkbar = log(2*ones(N,1));  %Exogenous capital
LAMBDA = (I-A')\bet;
ALPH   = diag(alph_sec);
ALPHK  = diag(alphk_sec);
gamma  = log(LAMBDA);

tau   = nansum(A.*log(A),2);
kappa = LAMBDA'*tau + LAMBDA'*ALPHK*lgkbar -LAMBDA'*(I-ALPH)*gamma;

if ~isreal(kappa)
    error('Kappa is not real, dude.');
end

test = sum(A,2) + diag(ALPHK) + diag(I-ALPH);

if max(abs(test-1))>1e-10
    error('Shares don''t add up.');
end

%**************************************************************************
% Artificial TFP history & News Selection
%**************************************************************************
eyescale = eye(N)*1e-8;
ntfp = size(tfp,1);

tfp      = detrend(log(tfp))';  %After transpose, each row is a sector (cols are years)
mu_z     = mean(tfp,2);
cov_tfp  = cov(tfp')+eyescale;

%construct and save random draws
s     = RandStream('mt19937ar','seed',0);
zz    = mu_z + chol(cov_tfp)'*randn(s,N,S);

%Replace final periods with actual TFP
zz(:,end-ntfp+1:end)=tfp;

if nwt
    nsf = 1; %(unweighted) extreme realizations are more newsworthy
else
    nsf = 2; %(weighted) extreme realizations are more newsworthy
end

[~, s_ind]=news_sel_func(zz,nsf,omega_opt,mu_z);

if rand_news
   s_ind = randi(11,[1,length(s_ind)]);
end

%... or for random news
%    s_ind = randi(N,[1,S]);

%**************************************************************************
% Generate full information solution given NU
%**************************************************************************
LL=.01+zeros(N,S);%this is where we save labor choices
crit = 1;
while crit > 1e-12
    Lnew = (I-ALPH)*LAMBDA*(exp(LAMBDA'*(I-ALPH)*log(LL) + LAMBDA'*zz + kappa))./(sum(LL,1).^(1/nu));
    crit = max(max(abs(Lnew-LL)));
    LL   = relax*Lnew + (1-relax)*LL;
end

%% **************************************************************************
% Generate incomplete information solution
%**************************************************************************

%News peports that happen only 1 or 2 times cannot have a regression (will sub in full info solution)
[us_ind,ct]      = unique_count(s_ind);
drop_obs         = ct<3;
drop_idx         = us_ind(drop_obs);
us_ind(drop_obs) = [];

critl = 1; jj = 1;
LL_orig = LL;
while (critl > 1e-8 || jj < 10) && jj < 160
    LL_orig = relax*LL+(1-relax)*LL_orig;
    
    E_num = (I-ALPH)*LAMBDA*(exp(LAMBDA'*(I-ALPH)*log(LL_orig) + LAMBDA'*zz + kappa));
    E_den = sum(LL_orig,1).^(1/nu);
    
    for ss=us_ind
        
        %Relevant periods
        idx_kp   = s_ind==ss;     %Obs used for regression
        idx_kp2  = 1:sum(idx_kp); %Which fitted values to use
        idx_kp3  = idx_kp;        %Where to place in LL
        
        if ncnd
            %Use whole sample, not conditional sample for regression
            idx_kp  = true(1,length(s_ind)); 
            idx_kp2 = s_ind==ss;
            idx_kp3 = idx_kp2;
        end
            
       
            
        zz_new    = zz(:,idx_kp);
        
        % compute contional expectations for ratio A.30 in Appendix
        for n=1:N
            if n==ss
                zz_cond_n = zz_new(n,:);
            else
                zz_cond_n = zz_new([n,ss],:);
            end
            %Run regression
            XX       = [ones(1,size(zz_new,2));zz_cond_n];
            Enum_fit = (E_num(n,idx_kp)/XX)*XX(:,idx_kp2);
            Eden_fit = (E_den(:,idx_kp)/XX)*XX(:,idx_kp2);
            LL(n,idx_kp3)   = Enum_fit./Eden_fit;
        end
    end
    
    %(Remove?) Plug in full-info solution at new NU for sectors reported only 1x or 2x
    for ss = drop_idx
        %Relevant periods
        idx_kp    = s_ind==ss;
        zz_new    = zz(:,idx_kp);
        LL_new    = LL(:,idx_kp);
        crit = 1;
        while crit > 1e-12
            Lnew = (I-ALPH)*LAMBDA*(exp(LAMBDA'*(I-ALPH)*log(LL_new) + LAMBDA'*zz_new + kappa))./(sum(LL_new,1).^(1/nu));
            crit = max(max(abs(Lnew-LL_new)));
            LL_new = relax*Lnew + (1-relax)*LL_new;
        end
        LL(:,idx_kp) = LL_new;
    end
    
    C = exp(LAMBDA'*(I-ALPH)*log(LL) + LAMBDA'*zz + kappa);
    cc = log(C);
    
    %compute var-ratio
    stdc = std(cc);
    stdl = std(log(sum(LL,1)));
    
    critl = max(max(abs((LL-LL_orig)./LL_orig)));
    %disp(['Iter ' num2str(jj) ': ' num2str(critl, '%1.3e') '|nu: ' num2str(nu,'%2.3f'), '|std(y):' num2str(100*stdc, '%2.2f') '|std(l):' num2str(100*stdl, '%2.2f')]);
    jj = jj+1;
end
stdcc = stdc;
toc_tot = toc(tic0);
disp([num2str(toc_tot/60) ' minutes total.']);


%% **************************************************************************
% Solve the model with incomplete information, but no news
%**************************************************************************
crit  = 1;
LL_nn = LL;
jj    = 1;
while (crit > 1e-12 || jj < 20) && jj < 100
    
    LL_orig = relax*LL_nn + (1-relax)*LL_orig;
    E_num   = (I-ALPH)*LAMBDA*(exp(LAMBDA'*(I-ALPH)*log(LL_orig) + LAMBDA'*zz + kappa));
    E_den   = sum(LL_orig,1).^(1/nu);
    
    % compute contional expectations for ratio A.30 in Appendix
    for n=1:N
        %Run regression just on own sector TFP
        XX         = [ones(1,S);zz(n,:)];
        Enum_fit   = (E_num(n,:)/XX)*XX;
        Eden_fit   = (E_den(:,:)/XX)*XX;
        LL_nn(n,:) = Enum_fit./Eden_fit;
    end
    
    crit = max(max(abs(LL_nn-LL_orig)));
    ccnn = LAMBDA'*(I-ALPH)*log(LL_nn) + LAMBDA'*zz + kappa;
    jj = jj+1;

end


%% *****************************************************************************
% Full information solution, tuning NU to match partial info output volatility
%*****************************************************************************
crit = 1;
LL_full = LL;
nu_full = nu;
jj = 1;
while (crit > 1e-12 || jj < 20) && jj < 60
    Lnew    = (I-ALPH)*LAMBDA*(exp(LAMBDA'*(I-ALPH)*log(LL_full) + LAMBDA'*zz + kappa))./(sum(LL_full,1).^(1/nu_full));
    crit    = max(max(abs(Lnew-LL_full)));
    LL_full = .5*Lnew + .5*LL_full;
    ccfull  = LAMBDA'*(I-ALPH)*log(LL_full) + LAMBDA'*zz + kappa;
    stdc = std(ccfull);
    stdl = std(log(sum(LL_full,1)));
    if jj > 5 && jj < 60
        nustep  = 25*(stdcc-stdc);
        nustep  = sign(nustep)*min(.2,abs(nustep));
        nu_full = max(nu_full + nustep,.5);
    end 
    jj = jj+1;   
end

disp(['std(cc)|std(ccnn)|std(ccfull): ' num2str(100*std(cc),'%1.2f') '|' num2str(100*std(ccnn),'%1.2f') '|' num2str(100*std(ccfull),'%1.2f')])
disp(['std(ll)|std(llnn)|std(llfull): ' num2str(100*std(log(sum(LL))),'%1.2f') '|' num2str(100*std(log(sum(LL_nn))),'%1.2f') '|' num2str(100*std(log(sum(LL_full))),'%1.2f')])

%% *****************************************************************************
% Store outputs in data structure
%*****************************************************************************
ll     = log(sum(LL));
llfull = log(sum(LL_full));
llnn   = log(sum(LL_nn));

%Get fitted C
XX=[ones(1,S);zz];
cfit=(cc/XX)*XX;
lfit=(ll/XX)*XX;
dates=2007+(0:ntfp-1);

a.dates = dates;
a.critl = critl;

%Save hours stuff
a.hrs         = ll  (1,end-ntfp+1:end)  - mean(ll);
a.hrs_fit     = lfit(1,end-ntfp+1:end)  - mean(ll);
a.hrs_resid   = ll  (1,end-ntfp+1:end)  - lfit(1,end-ntfp+1:end);

a.hrs_full    = llfull(:,end-ntfp+1:end) - mean(llfull);
a.hrs_nn      = llnn  (:,end-ntfp+1:end) - mean(llnn);


%Save GDP stuff
a.gdp         = cc(1,end-ntfp+1:end)  - mean(cc);
a.gdp_fit     = cfit(1,end-ntfp+1:end)- mean(cc);
a.gdp_resid   = cc(1,end-ntfp+1:end)  - cfit(1,end-ntfp+1:end);

a.gdp_full    = ccfull(1,end-ntfp+1:end)  - mean(ccfull);
a.gdp_nn      = ccnn  (1,end-ntfp+1:end)  - mean(ccnn);

%Save dGDP
a.dgdp        = diff(cc  (1,end-ntfp+1:end),1);
a.dgdp_fit    = diff(cfit(1,end-ntfp+1:end),1);
a.dgdp_full   = diff(ccfull(1,end-ntfp+1:end),1);

%Variances
a.gdp_sd     = var(cc)^.5;
a.var_rat    = var(cfit)/var(cc);
a.var_rat_ll = var(lfit)/var(ll);
a.var_rat_sm = var(cfit(end-ntfp+1:end))/var(cc(end-ntfp+1:end));

%Labor correlations
a.corl = corr(log(LL)');
a.corlnn = corr(log(LL_nn)');

%Big histories
a.cc      = cc;
a.ccnn    = ccnn;
a.ccfull  = ccfull;
a.cfit    = cfit;

a.ll      = ll;
a.llnn    = llnn;
a.llfull  = llfull;

a.nu      = nu;
a.nu_full = nu_full;
a.toc_tot = toc_tot;

return

%% **************************************************************************
% TESTING EQUATIONS
%%**************************************************************************
TT=S;
YY=zeros(N,TT);
CC=zeros(1,TT);
UU=zeros(1,TT);
for ss=456
    
    Lvec=LL(:,ss);
    z   =zz(:,ss);
    
    %RAC checking equations
    Cvec = exp((I-A)^-1*(z + tau) + (I-A)^-1*(I-ALPH)*log(Lvec) + (I-A)^-1*ALPHK*lgkbar -(I-A)^-1*(I-ALPH+ALPHK)*gamma + log(bet(:)));
    
    %Back out other things
    W = (sum(Lvec)^(1/nu));
    C = exp(LAMBDA'*(I-ALPH)*log(Lvec) + LAMBDA'*z + kappa);
    c = log(C);
    CC(1,ss)=C;
    p =(I-A)\((I-ALPH+ALPHK)*gamma-(I-ALPH)*log(Lvec)-ALPHK*lgkbar- z -tau) + c*ones(N,1); %A.25 new draft
    P = exp(p);
    
    %RAC CHECKS EQUATIONS
    %A.22
    V = C*(I-A')^-1*bet(:);
    
    %A.27
    log(Cvec)-(c-p + log(bet(:)))
    
    %A.20
    (I-A)*p - ((I-ALPH+ALPHK)*log(V) - (I-ALPH)*log(Lvec) - ALPHK*lgkbar - z - tau)
    
    %A.8
    P.*Cvec-bet.*C
    
    %Def of V
    Q = V./P;
    
    %RAC: this eq seems wrong
    %Q = (LAMBDA.*C)./P;
    
    PQ = P.*Q;
    
    %Test A.12 - yes
    Qalt = zeros(N,1);
    for ii = 1:N
        Qalt(ii) = exp(z(ii))*Lvec(ii)^(1-ALPH(ii,ii))*exp(lgkbar(ii))^ALPHK(ii,ii);
        for jj = 1:N
            Qalt(ii) = Qalt(ii)*(A(ii,jj)*V(ii)/P(jj))^A(ii,jj);
        end
    end
    
    %A.2
    Calt = prod((Cvec./bet).^bet);
    
    Calt - C
    
    if max(isnan(Q))==0;
        YY(:,ss)=Q;
    else
        YY(:,ss)=zeros(N,1);
    end
    UU(1,ss)= mean(C) - sum(Lvec)^nu;
    
end
cc=log(CC);

