%% Make the Unrepresentativeness index

[~,b] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\行业代码.xlsx",'Sheet2');
snames = b(2:13,1);

% Dates we want to look at
date_range = [2007, 2018];

% % New heard index
% nws_heard = vect(notn,0,date_range)/100;  %Percent who heard no news
% nws_heard = -nws_heard + mean(nws_heard) + 1;  %Mean is 1


%% MAKE THE UNWEIGHTED & WEIGHTED EMPLOYMENT SERIES
ndat = period_ct(date_range(1),date_range(2),1);
ndat = ndat.index;

%population
load ../output_files/gdp_hrs_中国年度 pop_filtered
pop_tot   = pop_filtered; %vect(pop,0,date_range);

%construct sectoral employment, stock, and news panels
emp_panel = zeros(12,12);
nws_panel = zeros(12,12);
for ii = 1:12
    
    %Employment panel
    emp_panel(:,ii)  = vect(sector_emp{ii},0,date_range);
    
    %News coverage panel
    nws_panel(:,ii)  = vect(wghts_jjrb_zqsb_filt{ii},0,date_range);    
end
emp_panel = emp_panel;%./pop_tot;

%actual agg. & sectoral growth rates
d_emp        = diff(log(sum(emp_panel,2)));
d_emp_panel  = diff(log(emp_panel))       ; d_emp_panel(isnan(d_emp_panel)) = 0;

%emp shares (t and avg)
emp_shar_t = emp_panel./sum(emp_panel,2);
emp_shar   = mean(emp_shar_t);

%news shares
rwght = .5*(nws_panel(1:end-1,:)+nws_panel(2:end,:)); 
rwght = rwght./sum(rwght,2);

%three news weighted employment series
d_emp_w  = sum(d_emp_panel.*rwght,2);         %TV sector share weights
d_emp_wn = d_emp_w; %*nws_heard        %TV sector share*news heard weights

%relative to aggregate labor growth
dev_emp_w  = d_emp_w  - d_emp;
dev_emp_wn = d_emp_wn - d_emp;
