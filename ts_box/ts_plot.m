
%TS_PLOT - Plot one or more timeseries object nicely, with recession shading.
%
%
% usage
%
% ts_plot(ser1, ser2, ...)
%

function [f1 s] = ts_plot(varargin)



%In case the last argument is a set limits on the y-axis
if isnumeric(varargin{end})
    ylimits = varargin{end};
    varargin = varargin(1:end-1);
    gen_ylim = 0;
else
    gen_ylim = 1;
end

%Number of series
nser = length(varargin);

%Load NBER series from proper directory
try
    str = which('ts_plot');
    nber_dir = str(1:end-9);
    load([nber_dir, 'NBER_rec.mat'])
    nber = 1;
catch
    nber = 0;
    warning('Could not acccess saved NBER recession series');
end


%Used to find the earliest starting ts, and latest ending ts
starts = zeros(nser,1);
ends = zeros(nser,1);
for i = 1:nser
    starts(i) = varargin{i}.sd;
    ends(i) = varargin{i}.ed;
    freq(i) = varargin{i}.freq;
    tits{i} = varargin{i}.name;
end
start = min(starts);
ender = max(ends);

%Check to make sure of same freq
if ~(sum(freq==freq(1))==length(freq))
    error('Incompatible Frequencies, ts_plot requires al series to be eithe quaterly or monthly');
else
    freq=freq(1);
end


%Check for NBER Conversion
if nber && freq == 4
    NBER = M2Q(NBER);
elseif nber && freq == 1
    NBER = Q2A(M2Q(NBER));
end

%How many periods
start_y = floor(start/100);
per_start = mod(start,100);
end_y = floor(ender/100);
per_end = mod(ender,100);
nper = (end_y-start_y)*freq+per_end-per_start+1;

%Make a column of dates
date_col = zeros(nper,1);
date_col(1) = start;
for j = 1:nper-1
   date_col(j+1) =  MQ_index(date_col(j), 1, freq);
end


data = NaN*zeros(nper, nser);
%Make data cols
for j = 1:nser
    idx1 = find(date_col==starts(j));
    idx2= find(date_col==ends(j));
    data(idx1:idx2,j) = varargin{j}.dat;
end

%Creat the figure, set figure paper placement, number of cols and rows in figure
f1 = figure;
set(f1, 'PaperPosition', [.25, .25, 10, 5.5], 'paperorientation', 'landscape');
hold on
s = subplot(1,1,1);
s.FontSize = 12;

%Goal: divide in year-long block, at least 7, and place year label at first
%period of the year
digit_col = num2str(date_col)-'0';
step_y = ceil((end_y-start_y)/7)';
step   = step_y*freq(1);
xtick    = find(digit_col(:,end)==1, 1,'first'):step:length(date_col);
xticklab = round(date_col(xtick)/100);

xlabel('Year', 'FontSize', 16);
set(s, 'xtick', xtick, 'xticklabel', xticklab, 'xlim', [1,nper]);
s.YLim = [min(nanmin(data)),max(nanmax(data))];

ylim = s.YLim;

%Shade NBER dates
if nber
    nber_dates = vect(NBER, 0, [start, ender])>0;
    
    delta = .2;
    %Loop over each recession block
    [s, e] = nzero_block(nber_dates);
    for j = 1:length(s)
        p= patch([s(j)-delta, s(j)-delta, e(j)+delta e(j)+delta], [ylim(1),.999*ylim(end), .999*ylim(end), ylim(1)], 'c');
        set(p, 'facecolor', [.7 .7 .7], 'linestyle', 'none');
    end
    hold on
end

%Print data for each figure
p = zeros(1,nser);
for i = 1:nser
    color_list = {'b', 'r','k','g', 'c'};
    line_list = {'-', '-', '-.', '--', '--'};
    p(i) = plot(data(:,i),'linestyle',line_list{i}, 'LineWidth', 1.5, 'Color', color_list{i});hold on;
 
end
s = subplot(1,1,1);
XLim = s.XLim;
plot(XLim,[0,0], ':k');

  
legend(p,tits, 'Location', 'Northwest');


%**************************************************************************
% NZERO_BLOCK - Find the boundries of blocks of 1's given a vector of
% zeros.
%
% helper function - not fully documented.
%**************************************************************************


function [block_starts, block_ends] = nzero_block(dat)

block_starts = [];
block_ends = [];

if dat(1) == 1
    block_starts = 1;
end

for j = 2:length(dat)
    if dat(j) == 1 && dat(j-1) == 0
        block_starts = [block_starts, j];
    end
end

for j = 1:length(dat) -1
    if dat(j) == 1 && dat(j+1) == 0
        block_ends = [block_ends, j];
    end
end

if dat(end) == 1
    block_ends = [block_ends, length(dat)];
end

