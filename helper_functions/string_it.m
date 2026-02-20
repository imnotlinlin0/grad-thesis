%STRING_IT:  Convert a cell-array to all strings, even if the original is
%mixed strings and data,

function in = string_it(in)


for jj = 1:length(in(:))
    if ~isstr(in{jj})
        in{jj} = num2str(in{jj});
    end
end