%Obsolete, use index

function i = tMinus1(date)

warning ('Function tMinus1() is obsolete. Use index instead.');

temp = mod (date, 1900);
    q = mod (temp, 100);
    if q>1
        i= date-1;    
    else
        i = date - 100 +3; %-100 subtracts a year, +4 puts quaters back in
    end
end
