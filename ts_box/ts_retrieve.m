%ts_retrieve



function out = tsretrieve(daterange, varargin)

out = [];
for j = 1:length(varargin)


    [a,b] = findEnds(varargin{j}, daterange);
    out = [out, varargin{j}.dat(a:b,:)];


end