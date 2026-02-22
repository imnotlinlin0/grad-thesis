%This function returns a structure giving the base time period (1st quater)
%and real data index that goes witht that period:
%
% Location of Current Usage uknown.
%
%Usage: function base = getBaseYr (date)


function base = getBaseYr (date)
    base.index = 1;
    base.date = 194701;
    while base.date < date
        base.index = base.index +1;
        base.date = index (base.date);
    end