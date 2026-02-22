% SETLASTCP - Function for Credit Policy Table Makeing.
% Sets and save a variable LastCP YYYYMM so that it can be 
% accessed at any time.  Used by make_tables or one of its subfunctions.

function setLastCP (date)
    LastCP = date;
    save /export/home/a1rxc03/matlab/ryan_lib/creditpol/LastCP LastCP;
   