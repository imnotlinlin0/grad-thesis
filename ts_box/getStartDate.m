%This function will find the first period of viable data.
%Usage [i, date] = getStartDate (dataArray)


function start = getStartDate(data)
    start.date =194701;
    start.i = 1;
    while isinf(data(start.i)) | isnan(data(start.i))
        start.i = start.i+1;
        start.date = index(start.date);
    end

end

