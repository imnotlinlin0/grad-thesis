% DEMEAN - De-mean the columns of a matrix X, excluding NaN values.
%
% usage
%
% out = demean(X)



function [out,mu] = demean(X)

t = size(X,1);
n = size(X,2);
out = zeros(t,n);
mu = zeros(1,n);

for j = 1:n
    mu(j) = mean(X(:,j));
    out(:,j) = X(:,j) - mu(j);
end


function out = mean(v)

idx = ~isnan(v);
out = sum(v(idx))./sum(idx);