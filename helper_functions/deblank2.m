%Replaces matlab's deblank function which is not working properly.

function s = deblank2(s)

for jj = 1:length(s(:))
   tmp = s{jj};
   idx = ~isspace(tmp);
   s{jj} = tmp(idx);
end
   