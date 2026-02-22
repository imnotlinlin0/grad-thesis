%% Load employement by sector from CES via FRED

[~,~,raw]  = xlsread('cnp_sectors.xlsx','ces_corres');
raw        = raw(5:end,1:4);
sector_emp = cell(1,29);
for jj = 1:29
    sector_emp{jj} = ts_make(zeros(726,1),12,196001, 'Sector X');
end


%% Get sectoral labor market series from FRED
% clear mth qtr
% url = 'https://fred.stlouisfed.org/';
% c = fred(url);
% 
% sec_sv = cell(size(raw,1),1);
% 
% for jj = 1:size(raw,1)
%     tmp = raw{jj,4};
%     if ~isnan(tmp)
%     sec_sv{jj} = ts_fred(fetch(c,tmp));
%     end
% end
% close(c);
% 
% save ../output_files/sector_labor_raw sec_sv

%% Use saved FRED data
load ../output_files/sector_labor_raw
mnf = sector_emp{1};
% Load and add new data
for jj = 1:size(raw,1)
    tmp = raw{jj,4};
    if ~isnan(tmp)
        sec_tmp = sec_sv{jj};
        
        sector_emp{raw{jj,2}} = ts_plus(sector_emp{raw{jj,2}},sec_tmp);
        
        if strcmp(raw{jj,4}(1:min(end,7)),'CES6054'); %|| strcmp(raw{jj,4}(1:3),'USW') || strcmp(raw{jj,4}(1:3),'UST')
            mnf = ts_plus(mnf,sec_tmp);
        end
    end
        
end
% Sector 21 (other trans) needs to subtract 20 (motor vehicles)
sector_emp{21} = ts_minus(sector_emp{21},sector_emp{20});

%Make everything quaterly
for jj = 1:29
   sector_emp{jj} = M2Q(sector_emp{jj}); 
end


%%
% 1. 读取Excel并匹配你的数据格式（列：country/cnt/var/year/12个行业/Total/War lag）
[emp_data, emp_headers, ~] = xlsread('分行业就业人数.xlsx', 'Sheet1');  % 替换为你的Excel文件名
% emp_headers：第1行表头，行业列对应第5列到第16列（共12个行业：Agricultur~Other serv）
% emp_data：数值矩阵，第4列是year，第5-16列是12个行业的就业数据

% 筛选2007-2018年的数据
year_col = 1;  % Excel中第4列是year
target_years = 2007:2018;
year_mask = ismember(emp_data(:, year_col), target_years);  % 匹配目标年份的行索引
filtered_data = emp_data(year_mask, :);  % 筛选后仅保留2007-2018年的行

% 提取12个行业的就业数据（Excel第5-16列）
sector_col_start = 2;
sector_col_end = 13;
sector_data = filtered_data(:, 2:13);  % 12行（年份）×12列（行业）
nsector = size(sector_data, 2);  % 确认是12个行业


% 2. 初始化12个行业的年度就业时间序列（完全匹配你的Excel结构）
sector_emp = cell(1, nsector);  % 1×12 Cell数组，对应12个行业
for jj = 1:nsector
    % 提取第jj个行业的2007-2018年数据（sector_data第jj列）
    emp_jj = sector_data(:, jj);  % 12行×1列（2007-2018年该行业就业数）
    % 获取行业名称（从表头第5-16列提取）
    sector_name = emp_headers{1, sector_col_start + jj + 2};
    % 构建年度时间序列（频率1=年度，起始年2007）
    sector_emp{jj} = ts_make(emp_jj, 1, 2007, [sector_name, '就业人数（2007-2018）']);
end
