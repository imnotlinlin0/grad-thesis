%% Load CNP sector definitions
[~,~,c] = xlsread('../cnp_sectors', 'use_corres');
snames = c(2:end-1,1);
c = string_it(c(2:end,2:end));

%Drop G
c = c(1:end-1,:) ;
nsec = length(c);

fname = ['../output_files/IO', num2str(nsec)];

bea_dates = 2007;   %2007 benchmark tables is our benchmark
nt        = length(bea_dates);

IOgr      = zeros(nsec,nsec,nt);
tot_mat   = zeros(nsec,1   ,nt);
tot_lab   = zeros(nsec,1   ,nt);
tot_out   = zeros(nsec,1   ,nt);
tot_fin   = zeros(nsec,1   ,nt);
tot_im    = zeros(nsec,1   ,nt);
tot_ex    = zeros(nsec,1   ,nt);
gshr_bea = zeros(nt,nsec);

%% For each period in dataset
for tt = 1:nt
    
    % Load direct requirements tables
    dstr = num2str(bea_dates(tt));
    
    %Load IO table for each year
    [a,b] = xlsread('IOUse.xlsx', dstr, 'A6:BU79');
    
    %Load totals stats for each sector
    [tot_inter]  = xlsread('IOUse.xlsx', dstr, 'C83:BU83');
    [tot_comp]   = xlsread('IOUse.xlsx', dstr, 'C84:BU84');
    [tot_va  ]   = xlsread('IOUse.xlsx', dstr, 'C87:BU87');
    
    %ALL Final Uses
    [tot_final ]  = xlsread('IOUse.xlsx', dstr, 'CU8:CU78');
    
    %Imports
    [tot_imp ]  = xlsread('IOUse.xlsx', dstr, 'CF8:CF78');
    tot_imp = -[tot_imp;0;0]; %Imports come as negative numbers
    tot_imp(isnan(tot_imp)) = 0;
   
    %Exports
    [tot_exp ]  = xlsread('IOUse.xlsx', dstr, 'CE8:CE78');
    tot_exp = [tot_exp;0;0];  
    tot_exp(isnan(tot_exp)) = 0;
    
    %Gross output
    [tot_output] = xlsread('IOUse.xlsx', dstr, 'C90:BU90');
    
    %codes for sectors that use the input
    dest_codes = deblank2(b(1,3:end));
    
    %codes for sector providing the input
    orig_codes = deblank2(b(3:end-1,1));
    
    %Blanks are just zeros
    a = a(1:71,1:71); a(isnan(a))=0;
    
    % find matching cols/rows for each sector
    orig_tot = 0;
    dest_tot = 0;
    dest_keep = zeros(nsec,71);
    orig_keep = zeros(nsec,71);
    %for each sector
    for ss = 1:nsec
        
        %for subsector includes in the Atalay sector
        idx = 1;
        while idx<=size(c,2) && ~strcmp(c(ss,idx), 'NaN')
            
            %find matching sectors
            dest_keep(ss,:) = dest_keep(ss,:)+strncmp(c{ss,idx},dest_codes,length(c{ss,idx}));
            orig_keep(ss,:) = orig_keep(ss,:)+strncmp(c{ss,idx},orig_codes(1:71),length(c{ss,idx}))';
            
            idx = idx+1;
        end
        dest_tot = dest_tot + dest_keep(ss,:);
        orig_tot = orig_tot + orig_keep(ss,:);
    end
    
    
    % Construct IO matrix, rows are inputs, cols are dest sector
    for jj = 1:nsec
        %Compute BEA total intermediate: includes used inputs and non-comparable imports
        tot_mat(jj,:,tt) = sum(tot_inter(logical(dest_keep(jj,:))));
        
        %Compute BEA total labor
        tot_lab(jj,:,tt) = sum(tot_comp((logical(dest_keep(jj,:)))));
        
        %Compute BEA gross output
        tot_out(jj,:,tt) = sum(tot_output((logical(dest_keep(jj,:)))));
        
        %Compute BEA use in final goods
        tot_fin(jj,:,tt) =  nansum(tot_final((logical(dest_keep(jj,:)))));
        
        %Compute BEA exports
        tot_ex(jj,:,tt)  =  nansum(tot_exp((logical(dest_keep(jj,:)))));
        
        %Compute BEA imports 
        tot_im(jj,:,tt)  =  nansum(tot_imp((logical(dest_keep(jj,:)))));
        
        %Compute inputs for each sector
        for ii = 1:nsec
            IOgr(ii,jj,tt) = sum(sum(a(logical(orig_keep(ii,:)),logical(dest_keep(jj,:)))));
        end
    end
    
    %Gross shares, measured two ways (including capital income, and excluding it)
    gshr_bea(tt,:)  = (tot_out(:,:,tt)')./sum(tot_out(:,:,tt));
    
    IOgr(:,:,tt) = IOgr(:,:,tt)';  % so rows are destination, cols are origin sector
end

%%
inter_used    = sum(IOgr,2);                  %Intermediates used by each sector.
inter_abs     = sum(IOgr,1);                 %Total intermediate absorption in each sector
gross_out     = tot_out + tot_im - tot_ex;    %Total overall absorption  in each sector
kap_shr       = zeros(size(tot_lab));         %Baseline model assumes zero capital share.


% Sum numbers over all years
alphi_sec   = sum(inter_used ,3)./sum(gross_out,3);
alphk_sec   = sum(kap_shr,3)./sum(gross_out,3);
alph_sec    = alphi_sec + alphk_sec;
A           = diag(sum(gross_out,3))\sum(IOgr,3);

%Shares in final absorbtion
bet         = sum(gross_out,3)-sum(inter_abs,3)';
bet         = bet./sum(bet);

%For main paper calibration
save(fname, 'A', 'bet*', 'alphi_sec', 'alphk_sec', 'alph_sec');

%%
% Chinese version starts here

%% Load CNP sector definitions
% [~,~,c] = xlsread("行业代码.xlsx", 'Sheet2');
% snames = c(2:13,1);
% c = string_it(c(2:13,2:end));
% 
% %Drop G
% c = c(1:end-1,:) ;
% nsec = size(c,1);

[~,~,klems_list] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\BEA_io\CIP_4.0_(2023)_IO_table_split_by_year.xlsx", '2007', 'C2:C38'); 
klems_codes = cellfun(@(x) char(x(~isnan(x))), klems_list(:,1), 'UniformOutput', false); 
% 关键1：和映射表用完全一致的strtrim清洗，而非deblank
klems_codes = cellfun(@strtrim, klems_codes, 'UniformOutput', false); 
klems_codes = klems_codes(~cellfun(@isempty, klems_codes)); 
klems_idx = containers.Map(klems_codes, 1:length(klems_codes)); 

% 调试：输出IO表的KLEMS字符（让你看匹配的基准）
disp('IO表提取的KLEMS字符：'); disp(klems_codes);

[~,~,c] = xlsread("行业代码.xlsx", 'Sheet2');
snames = c(2:13,1); 
c_char = c(2:13,2:end); 

c = cell(size(c_char));
for ss = 1:size(c_char,1)
    idx = 1;
    while idx<=size(c_char,2) && ~isempty(strtrim(char(c_char{ss,idx})))
        curr_str = strtrim(char(c_char{ss,idx})); 
        % 调试：输出当前映射表的字符，对比是否和IO表一致
        disp(['映射表第',num2str(ss),'行第',num2str(idx),'列字符：',curr_str]);
        if isKey(klems_idx, curr_str)
            c{ss,idx} = klems_idx(curr_str); 
        else
            c{ss,idx} = NaN; 
        end
        idx = idx+1;
    end
end

c = c(1:end-1,:) ; % 保留所有ETD行业
nsec = size(c,1);

fname = ['../output_files/IO', num2str(nsec)];

bea_dates = 2007:2017;   %2007 benchmark tables is our benchmark
nt        = length(bea_dates);

IOgr      = zeros(nsec,nsec,nt);
tot_mat   = zeros(nsec,1   ,nt);
tot_lab   = zeros(nsec,1   ,nt);
tot_out   = zeros(nsec,1   ,nt);
tot_fin   = zeros(nsec,1   ,nt);
tot_im    = zeros(nsec,1   ,nt);
tot_ex    = zeros(nsec,1   ,nt);
gshr_bea = zeros(nt,nsec);

%% For each period in dataset
for tt = 1:nt
    
    % Load direct requirements tables
    dstr = num2str(bea_dates(tt));
    curr_yr = bea_dates(tt); % 当前循环年份（如2007、2008...2018）

    %Load IO table for each year
    [a,b] = xlsread('CIP_4.0_(2023)_IO_table_split_by_year.xlsx', dstr, 'C1:AN38');

    

    %Load totals stats for each sector
    [tot_inter]  = sum(a,1) ;                   %xlsread('IOUse.xlsx', dstr, 'C83:BU83');
    tot_inter = tot_inter';
    
    %[tot_comp]   = xlsread('IOUse.xlsx', dstr, 'C84:BU84');
    [tot_comp,~,raw] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\BEA_io\CIP_4.0_(2023)_compensation.xlsx", 'Labor compensation');
    logic_cell = cellfun(@(x) isnumeric(x) && x == curr_yr, raw(1, :), 'UniformOutput', false);
    logic_arr = cell2mat(cellfun(@(y) y(1), logic_cell, 'UniformOutput', false));
    col_idx = find(logic_arr);
    tot_comp = tot_comp(2:38, col_idx); % 转置后维度：1×37，与你需要的格式完全匹配

    
    %[tot_va  ]   = xlsread('IOUse.xlsx', dstr, 'C87:BU87');
    [tot_va,~,raw] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\BEA_io\CIP_4.0_(2023)_gross value added.xlsx", 'Sheet1');
    logic_cell = cellfun(@(x) isnumeric(x) && x == curr_yr, raw(1, :), 'UniformOutput', false);
    logic_arr = cell2mat(cellfun(@(y) y(1), logic_cell, 'UniformOutput', false));
    col_idx = find(logic_arr);
    tot_va = tot_va(2:38, col_idx); % 转置后维度：1×37，与你需要的格式完全匹配

        
    %Imports
    % [tot_imp ]  = xlsread('IOUse.xlsx', dstr, 'CF8:CF78');
    % tot_imp = -[tot_imp;0;0]; %Imports come as negative numbers
    % tot_imp(isnan(tot_imp)) = 0;
    [tot_imp,~,raw] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\BEA_io\CIP_4.0_(2023)_final demand.xlsx", 'Import');
    logic_cell = cellfun(@(x) isnumeric(x) && x == curr_yr, raw(1, :), 'UniformOutput', false);
    logic_arr = cell2mat(cellfun(@(y) y(1), logic_cell, 'UniformOutput', false));
    col_idx = find(logic_arr);
    tot_imp = -tot_imp(2:38, col_idx); % 转置后维度：1×37，与你需要的格式完全匹配

    %Exports
    % [tot_exp ]  = xlsread('IOUse.xlsx', dstr, 'CE8:CE78');
    % tot_exp = [tot_exp;0;0];  
    % tot_exp(isnan(tot_exp)) = 0;
    [tot_exp,~,raw] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\BEA_io\CIP_4.0_(2023)_final demand.xlsx", 'Export');
    logic_cell = cellfun(@(x) isnumeric(x) && x == curr_yr, raw(1, :), 'UniformOutput', false);
    logic_arr = cell2mat(cellfun(@(y) y(1), logic_cell, 'UniformOutput', false));
    col_idx = find(logic_arr);
    tot_exp = tot_exp(2:38, col_idx); % 转置后维度：1×37，与你需要的格式完全匹配

    %Consumption
    [tot_consump,~,raw] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\BEA_io\CIP_4.0_(2023)_final demand.xlsx", 'Consumption');
    logic_cell = cellfun(@(x) isnumeric(x) && x == curr_yr, raw(1, :), 'UniformOutput', false);
    logic_arr = cell2mat(cellfun(@(y) y(1), logic_cell, 'UniformOutput', false));
    col_idx = find(logic_arr);
    tot_consump = tot_consump(2:38, col_idx); % 转置后维度：1×37，与你需要的格式完全匹配

    %Gross Capital Formation
    [tot_cap,~,raw] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\BEA_io\CIP_4.0_(2023)_final demand.xlsx", 'Gross Capital Formation');
    logic_cell = cellfun(@(x) isnumeric(x) && x == curr_yr, raw(1, :), 'UniformOutput', false);
    logic_arr = cell2mat(cellfun(@(y) y(1), logic_cell, 'UniformOutput', false));
    col_idx = find(logic_arr);
    tot_cap = tot_cap(2:38, col_idx); % 转置后维度：1×37，与你需要的格式完全匹配

    %ALL Final Uses
    tot_final = tot_consump+tot_cap+tot_imp+tot_exp;

    %Gross output
    %[tot_output] = xlsread('IOUse.xlsx', dstr, 'C90:BU90');
    [tot_output,~,raw] = xlsread("D:\摸鱼\毕业论文\毕业论文\code\BEA_io\CIP_4.0_(2023)_growth accounts.xlsx", 'Nominal GO');
    logic_cell = cellfun(@(x) isnumeric(x) && x == curr_yr, raw(1, :), 'UniformOutput', false);
    logic_arr = cell2mat(cellfun(@(y) y(1), logic_cell, 'UniformOutput', false));
    col_idx = find(logic_arr);
    tot_output = tot_output(2:38, col_idx); 
    
    %codes for sectors that use the input
    dest_codes = deblank2(b(1,2:38));
    
    %codes for sector providing the input
    orig_codes = deblank2(b(2:38,1));
    
    %Blanks are just zeros
    a = a(1:37,1:37); a(isnan(a))=0;
    
    % find matching cols/rows for each sector
    orig_tot = 0;
    dest_tot = 0;
    dest_keep = zeros(nsec,37);
    orig_keep = zeros(nsec,37);

    
    %for each sector
    % for ss = 1:nsec
    % 
    %     %for subsector includes in the Atalay sector
    %     idx = 1;
    %     while idx<=size(c,2) && ~strcmp(c(ss,idx), 'NaN')
    % 
    %         %find matching sectors
    %         dest_keep(ss,:) = dest_keep(ss,:)+strcmp(c{ss,idx},dest_codes); %,length(c{ss,idx})
    %         orig_keep(ss,:) = orig_keep(ss,:)+strcmp(c{ss,idx},orig_codes)'; %,length(c{ss,idx})
    % 
    %         idx = idx+1;
    %     end
    %     dest_tot = dest_tot + dest_keep(ss,:);
    %     orig_tot = orig_tot + orig_keep(ss,:);
    % %disp("这里")
    % end

    for ss = 1:nsec
        idx = 1;
        % 终止条件：空值/NaN终止
        while idx<=size(c,2) && ~isempty(c{ss,idx}) && ~isnan(c{ss,idx})
            % 核心修改：用索引直接标记，无需字符比较
            klems_id = c{ss,idx}; % 当前ETD母行业对应的KLEMS索引
            dest_keep(ss,klems_id) = 1; % 标记该KLEMS索引属于当前ETD母行业
            orig_keep(ss,klems_id) = 1; % 行/列方向统一标记
            idx = idx+1;
        end
        dest_tot = dest_tot + dest_keep(ss,:);
        orig_tot = orig_tot + orig_keep(ss,:);
    end
    
    %disp("这里")
    % Construct IO matrix, rows are inputs, cols are dest sector
    for jj = 1:nsec
        
        %Compute BEA total intermediate: includes used inputs and non-comparable imports
        tot_mat(jj,:,tt) = sum(tot_inter(logical(dest_keep(jj,:))));
        
        %Compute BEA total labor
        tot_lab(jj,:,tt) = sum(tot_comp((logical(dest_keep(jj,:)))));
        
        %Compute BEA gross output
        tot_out(jj,:,tt) = sum(tot_output((logical(dest_keep(jj,:)))));
        
        %Compute BEA use in final goods
        tot_fin(jj,:,tt) =  nansum(tot_final((logical(dest_keep(jj,:)))));
        
        %Compute BEA exports
        tot_ex(jj,:,tt)  =  nansum(tot_exp((logical(dest_keep(jj,:)))));
        
        %Compute BEA imports 
        tot_im(jj,:,tt)  =  nansum(tot_imp((logical(dest_keep(jj,:)))));
        
        %Compute inputs for each sector
        for ii = 1:nsec
            IOgr(ii,jj,tt) = sum(sum(a(logical(orig_keep(ii,:)),logical(dest_keep(jj,:)))));
        end
    end
    
    %Gross shares, measured two ways (including capital income, and excluding it)
    gshr_bea(tt,:)  = (tot_out(:,:,tt)')./sum(tot_out(:,:,tt));
    
    IOgr(:,:,tt) = IOgr(:,:,tt)';  % so rows are destination, cols are origin sector
end

%%
inter_used    = sum(IOgr,2);                  %Intermediates used by each sector.
inter_abs     = sum(IOgr,1);                 %Total intermediate absorption in each sector
gross_out     = tot_out + tot_im - tot_ex;    %Total overall absorption  in each sector
kap_shr       = zeros(size(tot_lab));         %Baseline model assumes zero capital share.


% Sum numbers over all years
alphi_sec   = sum(inter_used ,3)./sum(gross_out,3);
alphk_sec   = sum(kap_shr,3)./sum(gross_out,3);
alph_sec    = alphi_sec + alphk_sec;
A           = diag(sum(gross_out,3))\sum(IOgr,3);

%Shares in final absorbtion
bet         = sum(gross_out,3)-sum(inter_abs,3)';
bet         = bet./sum(bet);

%For main paper calibration
save(fname, 'A', 'bet*', 'alphi_sec', 'alphk_sec', 'alph_sec');

