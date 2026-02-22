% GETDATERANGE - Gets Last Credit Pol Date
% This function gets the current date ranges, which has been set be
% setLastCP.
% Usage:  
% [date, name] = getLastCP()


function [date name] = getLastCP()
 load ~/matlab/ryan_lib/creditpol/LastCP;
 date = LastCP;
 name = sim_dir(date);
end
