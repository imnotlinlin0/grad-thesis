% LOAD_ALL:  Parent file for loading all the data from the various
% sources to generate the data for the VAR-based exercise in Section 7 of
% the paper.
%
% The data come from 4 different places
%
% (1) Current employment survery (CES) from BLS via FRED
% (2) Michigan Consumer Survery from Univ. of Michigan
% (3) SPF data from Philly Fed
% (4) News coverage data from us.


%% (1) Load the CES data from FRED
load_sectoral_emp

% %% (2) Load the MICHIGAN SURVEY data downloaded from http: ...
% [a,b]= xlsread('Michigan/redbk23.xls');
% %good = M2Q(ts_make(a(75:end,2),12,197801, 'Good News Heard')) ;
% %bad  = M2Q(ts_make(a(75:end,3),12,197801, 'Bad News Heard')) ;
% notn = ts_hp(M2Q(ts_make(a(75:end,4),12,197801, 'No News Heard')),160000) ; %Effectively linear detrend
% %indx = M2Q(ts_make(a(75:end,5),12,197801, 'Index News Heard')) ;

%% (3) SPF data for VAR
start_ = 2007;
end_   = 2018; 

% Growth Forecasts
%[a,b]     = xlsread('SPF/medianGrowth.xlsx','RGDP');
%cast_delt = ts_make(a(:,3)/400,4,196804, 'SPF median real GDP growth');

[a, b] = xlsread('D:\摸鱼\毕业论文\毕业论文\code\SVAR_data\万得GDP一致预测.xlsx', 'Sheet1');
% 步骤1：从b_pred中提取年份（b_pred第1列从第5行开始是年份字符串，如"2027/12/..."）
year_strs = b(5:5+size(a,1)-1, 1);  % 匹配a_pred的20行数据，提取对应年份列
years = cellfun(@(x) str2num(x(1:4)), year_strs);  % 取年份字符串前4位转数值（如"2007/12/..."→2007）
% 步骤2：筛选2007-2018年的预测数据
mask = (years >= 2007) & (years <= 2018);
pred_data = a(mask);  % 提取对应年份的预测增长率
% 步骤3：构建年度时间序列（1=年度频率，起始年2007）
time_vec = 2007:2018;  % 年度频率，对应筛选后的预测数据年份
% 2. 用MATLAB内置timeseries函数构建时间序列（替代自定义的ts_make）
cast_delt = timeseries(pred_data, time_vec);  % 核心替换：数值+时间向量→时间序列
cast_delt.Name = '万得GDP一致预测年度增长率';  % 设置时间序列名称（对应原ts_make的最后一个参数）


% FORECAST ERROR USING Nth Release
%[a,b]      = xlsread('SPF/routput.xlsx','DATA');
%dgdp_r3    = ts_make(a(:,3)/400,4,196503);

% 读取中国GDP不变价年度同比数据（a=实际增长率数值列，b=含年份的Cell列）
[a_real, b_real] = xlsread('D:\摸鱼\毕业论文\毕业论文\code\SVAR_data\GDP不变价 年度同比.xlsx', 'Sheet1');

% 步骤1：从b_real中提取年份（同预测数据结构，第5行开始为年份字符串，如"2007/12/..."）
year_strs_real= b_real(4:4+size(a_real,1)-1, 1);  % 匹配实际数据行数，提取对应年份列 
years_real = cellfun(@(x) str2num(x(1:4)), year_strs_real);  % 取年份字符串前4位转数值

% 步骤2：筛选2007-2018年的实际GDP增长率数据
mask_real = (years_real >= 2007) & (years_real <= 2018);
real_data = a_real(mask_real);  % 提取对应年份的实际GDP增长率

% 步骤3：用MATLAB内置timeseries构建dgdp_r3时间序列（年度频率）
time_vec = 2007:2018;  % 与筛选后的数据长度完全匹配（2007-2018共12个年度数据）
dgdp_r3 = timeseries(real_data, time_vec);  % 构建实际GDP增长率时间序列
dgdp_r3.Name = '中国GDP不变价年度同比增长率';  % 设置时间序列名称，明确数据含义

% 计算GDP预测误差（实际-预测，逻辑不变，适配年度数据）
nce_rgdp_3 = dgdp_r3 - cast_delt ;
% 标准化数据（移除×400，年度数据无需转换）

% 2. 替代 dgdp_r3 = vect(dgdp_r3, 0, [start_, end_])：筛选时间+调整维度（适配VAR输入）
% 筛选2007-2018年的时间索引（确保与目标范围完全匹配）
dgdp_time_idx = find(dgdp_r3.Time >= start_ & dgdp_r3.Time <= end_);
% 提取对应时间的实际GDP增长率数值，维度为“时间点×1”（12行×1列，适配VAR模型“时间-指标”格式）
dgdp_r3 = dgdp_r3.Data(dgdp_time_idx);
% 转换为列向量（确保后续与nce_r3拼接时维度一致）
dgdp_r3 = reshape(dgdp_r3, [], 1);

% 3. 替代 nce_r3 = vect(nce_rgdp_3, 0, [start_, end_])：同逻辑处理预测误差
% 筛选预测误差的时间索引（与dgdp_r3时间范围对齐）
nce_time_idx = find(nce_rgdp_3.Time >= start_ & nce_rgdp_3.Time <= end_);
% 提取对应时间的预测误差数值
nce_r3 = nce_rgdp_3.Data(nce_time_idx);
% 转换为列向量（与dgdp_r3维度统一，便于构建var_data）
nce_r3 = reshape(nce_r3, [], 1);


% 构建VAR输入矩阵（中国年度数据：[预测误差, 实际增长率]）
var_data = [nce_r3, dgdp_r3];

%% (4) Load the news data and generate news weights, dispersion measures, etc
load_news_data

%% (5) Construct non-representativeness timseries
make_nonrep

%% (6) Save everything
var_desc = {'gdpv   '        , 'Real GDP'; 
            'pop'            , 'Populatiom, with rebasing jumps smoothed using HP filter per advice of Peter Ireland';
            'wghts_all'      , 'News weights using all papers, no filter';
            'wghts_all_filt' , 'News weights using all papers, with filter';
            'wghts_jjrb_zqsb_filt', 'News weights using all WSJ & NY times, with filter';
            'dev_emp_w'      , 'TV news weighted employment growth less TV share weighted employment growth'; 
            'dev_emp_wn'     , 'News heard-scaled TV news weighted employment growth less TV share weighted employment growth';
            };
save ../output_files/var_data var_data nce_r3 dgdp_r3 dev_emp_w dev_emp_wn var_desc wghts*

%'notn'           , 'News heard index Michigan Consumer Survey';

