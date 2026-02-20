function [out,ct] = unique_count(x)


out= unique(x);

ct = zeros(1,size(out,2));

for jj = 1:length(out)
    
   ct(jj) = sum(x==out(jj)); 
end

