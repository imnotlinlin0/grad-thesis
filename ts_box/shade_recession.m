%**************************************************************************
% SHADE_RECESSION - Shade according to recessions (or any other boolean
% indicator variable.)
%
% usage:
%
% sub = shade_recession(sub, rec_ind)
%
% where
% 
% sub = a subplot handle
% rec_ind = an indicator for dates to shade.
%**************************************************************************

 

function sp = shade_recession(sp,rec)

%Retrieve data from all the plots
ylim = get(sp, 'ylim');
xlim = get(sp, 'xlim');
pl   = get(sp, 'children');

for k = 1:length(pl)
    x{k} = get(pl(k), 'xdata');
    y{k} = get(pl(k), 'ydata');
    style{k} = get(pl(k),'LineStyle');
    width{k} = get(pl(k), 'LineWidth');
    color{k} = get(pl(k), 'Color');
end

%Check input arguments

if length(x{1}) ~= length(rec)
    error('Data and Indicator of unequal legnths.');
end

delta = .2;
%Loop over each recession block
[s, e] = nzero_block(rec);
for j = 1:length(s)
    p= patch([s(j)-delta, s(j)-delta, e(j)+delta e(j)+delta], [ylim(1),.999*ylim(end), .999*ylim(end), ylim(1)], 'c');
    set(p, 'facecolor', [.7 .7 .7], 'linestyle', 'none');
end
hold on

%Replot the data on top of the boxes
for k = 1:length(pl)
  plot(x{k}, y{k}, 'LineStyle', style{k},'LineWidth', width{k}, 'color', color{k});
end

%Return axis to original scale
set(sp, 'xlim', xlim);


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
