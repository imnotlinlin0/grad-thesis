%This file converts the yyyyqq format to file names for the real time data 
%provided by the philly fed.


function name = DateToName(date)
   q = mod (date, 5);
   y = (date - q)/100;
   y = mod(y-1900, 100);

   
   %Gets the year in workable 2 digit form
   if y < 10
      year = strcat( '0', num2str(y));
   else
      year = num2str(y);
   end
	
   %Asembles name of file
   if q ==1
      name = strcat('feb' , year);
   elseif q == 2
      name = strcat('may' , year);
   elseif q ==3
      name = strcat('aug' , year);
   else
      name = strcat('nov' , year);
   end 
   