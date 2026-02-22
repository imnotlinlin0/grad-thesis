function result = quarterFormat(date)
    quarter = mod ( date, 10);
    year = (date - quarter)*100;
    result = year + quarter;
end
