function [wghtv,herfv,gniv] = make_news_wghts(a)

% 1. 核心参数适配：12个行业 + 2007-2018年年度数据（共12个观测值）
nsector = 12;                          % 替换原29个行业，改为你的12个行业
year_range = 2007:2018;                % 你的数据年份范围
n_year = length(year_range);           % 年度观测值数量（2018-2007+1=12）

% 2. 初始化变量：维度适配年度数据（n_year行×12列）
herf = zeros(n_year,1);                % 赫芬达尔指数：12行（每年1个值）
gni  = zeros(n_year,1);                % 基尼系数：12行（每年1个值）
wght = zeros(n_year,nsector);          % 新闻权重：12行（年）×12列（行业）
ctr  = 1;                              % 年度观测值计数（替代原季度计数）

% 3. 循环：仅年度循环（删除原季度循环，适配年度数据）
for yy = year_range    % 遍历2007-2018每一年
        
    % 3.1 筛选当前年份的所有新闻数据（a(:,9)为年份字段，与原代码逻辑一致）
    a_tmp = a(a(:,6) == yy,:);  % 提取第yy年的所有新闻记录
    
    % 3.2 无需季度筛选（年度数据直接用全年记录，删除原qq循环）
    a_tmp2 = a_tmp;  % 全年数据直接作为当前年度的分析样本
    
    % 3.3 统计每个行业的新闻提及次数（适配12个行业）
    ct_sector = zeros(1,nsector);  % 1行×12列，存储每个行业的提及次数
    for ii = 1:nsector
        % a(:,16)为行业标识字段（与原代码一致），统计第ii个行业的总提及次数
        ct_sector(ii) = sum(a_tmp2(a_tmp2(:,8) == ii,2));  
    end
    
    % 3.4 计算年度新闻权重（行业提及占比）
    total_mention = sum(ct_sector);
    if total_mention ~= 0  % 避免除以0（若某年度无新闻数据，权重设为0）
        wght(ctr,:) = ct_sector ./ total_mention;
    else
        wght(ctr,:) = zeros(1,nsector);
    end
    
    % 3.5 计算年度赫芬达尔指数（衡量新闻覆盖的集中度）
    herf(ctr) = sum((wght(ctr,:)).^2);  % 权重平方和，值越大集中度越高
    
    % 3.6 计算年度基尼系数（衡量新闻覆盖的不均衡度）
    [ct_ord,~] = sort(ct_sector, 'ascend');  % 行业提及次数升序排列
    % （原代码gini函数逻辑保留，若需启用可取消注释，确保gini函数适配12个行业）
    % gni(ctr) = gini(1/nsector*ones(1,nsector),ct_ord);  % 行业等权重计算基尼系数
    
    % 3.7 年度计数递增（每处理1年，计数+1）
    ctr = ctr + 1;
        
end

% 4. 构建年度时间序列（替换原季度频率，适配年度数据）
% ts_make参数：数值数组 + 频率（1=年度） + 起始年份 + 变量名
herfv = ts_make(herf, 1, 2007, 'Herf. of News (Annual)');  % 频率4→1，起始年1988→2007
gniv  = ts_make(gni , 1, 2007, 'Gini of News (Annual)');   % 同上

% 5. 构建12个行业的年度新闻权重时间序列（适配12个行业）
wghtv = cell(1,nsector);  % 1×12细胞数组，存储每个行业的权重序列
for ii = 1:nsector
    % 每个行业对应1条年度序列：2007-2018年权重
    wghtv{ii} = ts_make(wght(:,ii), 1, 2007, ['Sector ', num2str(ii) ' wght (Annual)']);
end

end