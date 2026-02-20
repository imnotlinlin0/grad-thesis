%load_file = 'indprod11.xlsx';
load = 'D:\A文件\A组会\毕业论文\code\BLS_multifactor\data_CN.xlsx';

%% Load CNP sector definitions
% [~,~,c] = xlsread('../cnp_sectors', 'multi_corres');
% cnp_names = c(2:end,1);
% c = string_it(c(2:end,2:end));
% nsec = size(c,1);
% 
% [~,~,d] = xlsread('../cnp_sectors', 'CNP Sectors (Summary)');
% d = string_it(d);
% 
% %% Map KLEMS sectors to their rows in the table (since used in all other sheets)
% %incl_titl = cell(size(c,1),1);
% for ss = 1:nsec
%     %for each included subsector
%     idx = 1;
%     idx2 = 2;
%     while idx<=size(c,2) && ~strcmp(c(ss,idx), 'NaN')
%         incl_tmp = d(strncmp(c{ss,idx},d(:,2),length(c{ss,idx})),1);
%         for jj = 1:length(incl_tmp)
%             cnp_names(ss,idx2) = incl_tmp(jj);
%             idx2 = idx2+1;
%         end
%         idx = idx+1;
%     end
% end

cnp_names = readcell('行业代码', 'Range', 'B2:U13', 'Sheet', 'Sheet2');
[rowNum, colNum] = size(cnp_names);  % 获取cell数组的行列数
for i = 1:rowNum
    for j = 1:colNum
        if ismissing(cnp_names{i,j})
            cnp_names{i,j} = '[]';  % 替换为NaN
        end
    end
end
nsec = size(cnp_names,1);
%cnp_names{8,1}
%% Create matrix for weighting subs-sectors in each CNP sector
[gdp_mil_in,titles] = xlsread("data_CN.xlsx", 'Gross output','B3:AG39');
usum = zeros(nsec,37); %sum the right rows for each CNP sector
nt = size(gdp_mil_in,2);
for ss = 1:nsec
    for ii = 2:size(cnp_names,2)
        if isempty(cnp_names{ss,ii});break;end
        idx_incl = strcmpi(cnp_names(ss,ii),titles);
        usum(ss,:) = usum(ss,:)+idx_incl';
    end
end

% Create a matrix that sums with gross weights based on nominal output for each period
wsum = zeros(nsec,37,nt);
usum = logical(usum);
for tt = 1:nt
    for ss = 1:nsec
        wsum(ss,:,tt) = usum(ss,:).*gdp_mil_in(:,tt)'./sum(gdp_mil_in(usum(ss,:),tt));
    end
end

gross_late = usum*gdp_mil_in;


%% Gross output quantity indexes
[gdp_late_in] = xlsread(load, 'Gross output quantity','B3:AG39');
gdp_late = zeros(nsec,nt);
for tt = 1:nt
    gdp_late(:,tt) = wsum(:,:,tt)*gdp_late_in(:,tt);
end

%% Labor quantity indexes
[labor_late_in] = xlsread(load, 'Labor input quantity','B4:AG40');
labor_late = zeros(nsec,nt);
for tt = 1:nt
    labor_late(:,tt) = wsum(:,:,tt)*labor_late_in(:,tt);
end

%% Labor Compensation in Millions
[comp_late_in] = xlsread(load, 'Labor compensation','B4:AG40');
comp_late = usum*comp_late_in;

%% VA Million
[va_late_in] = xlsread(load, 'Value added','B3:AG39');
va_late = usum*va_late_in;

%% TFP indexes
[tfp_late_in] = xlsread("data_CN.xlsx", 'TFP index','B4:AG40');
tfp_late = zeros(nsec,nt);
for tt = 1:nt
    tfp_late(:,tt) = wsum(:,:,tt)*tfp_late_in(:,tt);
end


%% Save_output

%Transpose. Cols are sectors, rows are years.
gdp       = gdp_late';
tfp       = tfp_late';
labor     = labor_late';
comp      = comp_late';
gross_mil = gross_late';
va_mil    = va_late';  

%Drop G
gdp       = gdp  (:,1:nsec-1);
tfp       = tfp  (:,1:nsec-1);
labor     = labor(:,1:nsec-1);
comp      = comp (:,1:nsec-1);
gross_mil = gross_mil(:,1:nsec-1);
va_mil    = va_mil   (:,1:nsec-1);
nms = cnp_names(1:nsec-1,1)';

gdp_cell   = [num2cell([NaN;(1987:1:2017)']),[nms;num2cell(gdp)]];
tfp_cell   = [num2cell([NaN;(1987:1:2017)']),[nms;num2cell(tfp)]];
labor_cell = [num2cell([NaN;(1987:1:2017)']),[nms;num2cell(labor)]];
gross_cell = [num2cell([NaN;(1987:1:2017)']),[nms;num2cell(gross_mil)]];

writecell(gdp_cell  ,'../output_files/multifactor_output.xlsx', 'Sheet','Output (index)');
writecell(tfp_cell  ,'../output_files/multifactor_output.xlsx', 'Sheet','TFP (index)');
writecell(labor_cell,'../output_files/multifactor_output.xlsx', 'Sheet','Labor (index)');
writecell(gross_cell,'../output_files/multifactor_output.xlsx', 'Sheet','Output (gross millions)');

save ../output_files/tfp tfp

