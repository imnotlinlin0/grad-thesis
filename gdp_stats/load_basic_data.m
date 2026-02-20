% %% Basic Macro Time-series and including some labor market series
% clear mth qtr
% url = 'https://fred.stlouisfed.org/';
% c = fred(url);
% 
% %Main BEA Series
% qtr.gdp  = fetch(c,'GDP');       % gdp
% qtr.def = fetch(c,'GDPDEF');     % deflator
% 
% %BLS Population
% qtr.pop = fetch(c,'CNP16OV');    % noninstitutional population
% 
% %Employment Measures (BLS: Productivity and Costs)
% qtr.hrs   = fetch(c,'HOANBS');      %hours worked
% 
% date_loaded = datestr(today);
% 
% close(c);
% 
% save ../output_files/gdp_hrs_raw.mat qtr date_loaded

%% Use previously-save data from FRED

load ../output_files/gdp_hrs_raw

%Population Series Smoothed
[~,pop]  = ts_hp(M2Q(ts_fred(qtr.pop)),1600);

%Quarterly Quantities
gdp  = ts_fred(qtr.gdp);
defl = ts_fred(qtr.def);
hrs  = ts_fred(qtr.hrs);

%Real GDP
gdpv     = ts_div(gdp,defl);

%Annual data
dates_a = [198701,201801];

%Annual gdp-per-capita
gdp_pca =  ts_log(Q2A(ts_div(   gdpv  ,pop)));
hrsa    =  ts_log(Q2A(ts_div(   hrs   ,pop)));

%Annual average GDP/ Hours
gdp_a  = vect(gdp_pca,0,dates_a);
hrs_a  = vect(hrsa   ,0,dates_a);

save ../output_files/gdp_hrs gdp_a hrs_a pop


%% 这里是正确代码！！！！%%
%                         %
% 读取中国年度劳动力人口数据（Excel结构：A列"年份"，B列"劳动力人口（万人）"）
pop_table = readtable('/劳动力人口 中国.xlsx', 'VariableNamingRule', 'preserve');
% 日期转换：年度数据统一用每年1月1日作为时间节点
% 步骤1：用列索引提取A列（年份列），避免列名错误（A列对应第1列，索引为1）
year_column = pop_table(:, 1); % 直接取第1列，无需依赖列名
year_data = year_column{:, 1}; % 转换为单元格数组，便于清洗

% 步骤2：清洗非数值年份数据（处理"2000年""2000-"等文本格式）
% 提取字符串中的数字部分，转换为实数
pop_years = str2double(regexp(year_data, '\d{4}', 'match', 'once'));

% 步骤4：日期转换（此时pop_years已为纯实数，可正常运行）
pop_dates = datenum(pop_years, 1, 1); % 年度日期格式（YYYY-01-01）
% 构建年度时间序列（频率=1）
qtr.pop.dates = pop_dates;          % 存储年度日期（datenum格式，如2000-01-01）
qtr.pop.data = pop_table.("劳动力人口"); % 存储劳动力人口数据（原数值，单位：万人）
qtr.pop.frequency = 1;              % 标注频率：1=年度（与原代码一致）

[pop, ~] = hpfilter(qtr.pop.data, 100); % 100=年度数据HP滤波参数，pop_trend=平滑后的人口数据
%pop = pop_trend; 
 
% 读取中国年度不变价GDP数据（Excel结构：A列"统计年度"，B列"不变价GDP（亿元）"）
gdp_table = readtable('/GDP 不变价 年度数据.xlsx', 'VariableNamingRule', 'preserve');
% 日期转换：同劳动力人口，用年度首日
gdp_years = gdp_table.("年份"); % 假设列名为"统计年度"
gdp_dates = datenum(gdp_years, 1, 1);
% 单位转换："亿元"→"元"（匹配原美国数据单位），构建年度时间序列
qtr.gdp.dates = gdp_dates;          % 存储GDP的年度日期
qtr.gdp.data = gdp_table.("GDP(不变价)"); % 存储GDP数据
qtr.gdp.frequency = 1;              % 标注年度频率



% 读取中国年度周均工时数据（Excel结构：A列"年度"，B列"周平均工作时间（小时）"）
hrs_table = readtable('/城镇就业人员周平均工作时间合计_20251221_010234.xlsx', 'VariableNamingRule', 'preserve');
hrs_table(24:end,:) = [];
% 日期转换：年度时间节点
year_column2 = hrs_table(:, 1); % 直接取第1列，无需依赖列名
year_data2 = year_column2{:, 1}; % 转换为单元格数组，便于清洗


hrs_years = hrs_table.("年份"); % 假设列名为"年度"
hrs_dates = datenum(hrs_years, 1, 1);
% 换算为年度总工时：周均工时×52周（年度约52周，匹配原文章"总工作小时"指标定义）
annual_hrs = hrs_table.("城镇就业人员:周平均工作时间:合计") * 52;
% 构建年度工时时间序列
qtr.hrs.dates = hrs_dates;          % 存储GDP的年度日期
qtr.hrs.data = annual_hrs; % 存储GDP数据
qtr.hrs.frequency = 1;  

date_loaded = datestr(today);
% 新增"中国年度"后缀，区分原季度数据与中国季度数据
save ../output_files/gdp_hrs_raw_中国年度.mat qtr date_loaded

% 替换为中国年度原始数据路径
load ../output_files/gdp_hrs_raw_中国年度.mat

% 关键调整：年度数据HP滤波标准参数λ=100（原季度数据λ=1600），避免过度平滑
% 无需M2Q（月度转季度）函数，直接处理年度人口数据


% 1. 实际GDP：直接用年度不变价GDP，删除defl（平减指数）相关代码
gdpv = qtr.gdp.data;  % 跳过"gdpv = ts_div(gdp, defl)"

% 2. 工时数据：直接读取年度总工时，无需季度转换
hrs = qtr.hrs.data;

% 步骤1：从日期（datenum格式）中提取年份，用于匹配时间范围
pop_years = year(datenum(qtr.pop.dates)); % 人口数据对应的年份
gdp_years = year(datenum(qtr.gdp.dates)); % GDP数据对应的年份
hrs_years = year(datenum(qtr.hrs.dates)); % 工时数据对应的年份

% 步骤2：定义目标样本期（2007-2018年），找到各变量在该区间的索引
target_years = 2007:2018;
% 分别获取GDP、人口、工时在目标期内的索引
gdp_idx = ismember(gdp_years, target_years);
pop_idx = ismember(pop_years, target_years);
hrs_idx = ismember(hrs_years, target_years);

% 步骤3：按索引筛选数据，确保三者长度完全一致（均为12个年度数据，2007-2018）
gdpv_filtered = qtr.gdp.data(gdp_idx); % 筛选后GDP
pop_filtered = pop(pop_idx);           % 筛选后平滑人口
hrs_filtered = qtr.hrs.data(hrs_idx);  % 筛选后工时

% 关键调整：无需Q2A（已为年度数据），直接计算人均对数指标
gdp_pca = log(gdpv_filtered ./ pop_filtered); % 中国人均实际GDP（对数，2007-2018）
hrsa = log(hrs_filtered ./ pop_filtered);     % 中国人均年度总工时（对数，2007-2018）

dates_a = [2007,2018];
% 1. 为gdp_pca构建vect函数需要的tseries结构体（含dat/freq/time字段，适配data.dat调用）
gdp_pca_ts.dat = gdp_pca(:);  % 转为列向量，适配vect第18行size(data.dat)判断
gdp_pca_ts.freq = 1;          % 年度数据频率，适配findEnds时间匹配
gdp_pca_ts.time = target_years; % 存储年份，供findEnds定位日期范围
gdp_pca_ts.sd = target_years(1);

% 2. 为hrsa构建相同格式的tseries结构体
hrsa_ts.dat = hrsa(:);        % 转为列向量，确保维度与gdp_pca_ts一致
hrsa_ts.freq = 1;             % 年度频率，与gdp_pca_ts统一
hrsa_ts.time = target_years;  % 年份信息，匹配目标样本期
hrsa_ts.sd = target_years(1);

% 2. 为hrsa构建相同格式的tseries结构体
pop_ts.dat =pop_filtered(:);        % 转为列向量，确保维度与gdp_pca_ts一致
pop_ts.freq = 1;             % 年度频率，与gdp_pca_ts统一
pop_ts.time = target_years;  % 年份信息，匹配目标样本期
pop_ts.sd = target_years(1);

% 3. 修正vect调用：传入结构体而非原始数值数组，解决"不支持点索引"问题
gdp_a = vect(gdp_pca_ts, 0, dates_a);
hrs_a = vect(hrsa_ts, 0, dates_a);
pop_filtered = vect(hrsa_ts, 0, dates_a);


% 保存中国年度处理后数据
save ../output_files/gdp_hrs_中国年度 gdp_a hrs_a pop_filtered

%%
% 加载 Excel 文件
gdp_data = readtable('/GDP 不变价 年度数据.xls.xlsx'); % GDP 数据
hrs_data = readtable('/城镇就业人员周平均工作时间合计_20251221_010234.xlsx'); % 每周工作小时数据
pop_data = readtable('/劳动力人口 中国.xlsx'); % 人口数据

% 确定所有数据的年份范围
gdp_years = gdp_data.年份;
hrs_years = hrs_data.年份;  % 这里假设 '年份' 是您数据中的列名
pop_years = pop_data.年份;

% 找到所有数据的共同年份范围
common_years = intersect(intersect(gdp_years, hrs_years), pop_years);

% 对齐 GDP 数据
qtr.gdp = gdp_data.GDP(ismember(gdp_years, common_years)); % 只选择共同年份的数据

% 对齐劳动力人口数据
qtr.pop = pop_data.劳动力人口(ismember(pop_years, common_years)); % 只选择共同年份的数据

% 对齐每周工作小时数据
qtr.hrs = hrs_data.('城镇就业人员:周平均工作时间:合计')(ismember(hrs_years, common_years)); % 只选择共同年份的数据

% 计算年度人均 GDP 和每周工作小时（单位：小时/周）
% 计算实际 GDP
gdpv = ts_div(qtr.gdp, defl); % 如果没有通货膨胀指数，您可以忽略这一行

% 计算年度人均 GDP 和每周工作小时
gdp_pca = ts_log(ts_div(gdpv, qtr.pop)); % 计算人均 GDP
hrsa = ts_log(ts_div(qtr.hrs, qtr.pop));  % 计算人均每周工作小时

% 定义年度数据范围
dates_a = [min(common_years), max(common_years)];

% 计算年度平均 GDP/小时
gdp_a = vect(gdp_pca, 0, dates_a);
hrs_a = vect(hrsa, 0, dates_a);

% 保存处理后的数据
save ../output_files/gdp_hrs gdp_a hrs_a qtr.pop
