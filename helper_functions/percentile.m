function out = percentile(X,per,dim)

if nargin == 3 && dim == 2
    X = X';
end

n = size(X,1);
np = round(per*n);

X = sort(X, 'ascend');

out = X(np,:);


if nargin == 3 && dim == 2
    out = out';
end