%Transpose each slice of a 3-d matrix

function out = transpose3rd(X)
nd = size(X);

if length(nd)==2
   nd(end+1) = 1; 
end

out = zeros(nd(2),nd(1),nd(3));
for jj = 1:nd(3)
    out(:,:,jj) = X(:,:,jj)';
end