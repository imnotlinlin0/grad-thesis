% VECT - Returns the data from a tseries data object
% 
% Usage: 
% result = vect (tseries, lead, conversions(optional), deflator(optional), dateRange(optional)) where
% where
% tseries = any tseries
% lead = the lead (negative for lag) nec
% conversion = one of '%','%-real', 'log', 'real', 'log-real', 'log-chg',
% 'chg'
% deflator =  special options are 'US' (jgdp), 'japan', 'eich'.  
% dateRange = a two element dateRange
%
% NOTES: Uses the dateRange stored in getDateRange() by default.  Haver's 
% gdpd is the default deflator
% 

function result = vect(data, lead, varargin)
if size(data.dat,1)>size(data.dat,2)
    data.dat = data.dat';
end


%Sets the data range

data = ts_lag (data, -lead);

%Sets the deflator - until we get a more dynamic series
%defl = prep_Japan(0);
%defl = tseries(exp(defl(:,3)), 196001, 4, 'defl');

%Check to see if special date range has been selected.
if ~isempty(varargin) && isnumeric(varargin{1})
    dateRange = varargin{1};
    varargin = {};
elseif size(varargin,2)>1 && isnumeric(varargin{2})
    dateRange = varargin{2};
    varargin = {varargin{1}};
elseif size(varargin,2) == 3
    dateRange = varargin{3};
    varargin = {varargin{1:2}};
else
    %Use default dateRange
    dateRange = getDateRange;
end

%Check for deflator request
if size(varargin,2) >1
    if ists(varargin{2})
        defl = varargin{2};
    elseif strcmpi(varargin(2), 'japan')
        defl = gethaver('c158gj');
    elseif strcmpi(varargin(2), 'us')
        defl = gethaver('jgdp');
    elseif strcmpi(varargin{2} , 'cpi')
        defl = mtoq(gethaver('pcuslfe'));
    elseif strcmpi(varargin{2}, 'eich')
        %Use eichenbaum's deflator
        dir = cd;
        cd /export/home/a1rxc03/matlab/eichenbaum;
        load pgdp;
        defl = pgdp;
        defl.dat = 100*defl.dat;
        eval (['cd ', dir]);
    else
        warning ('Invalid country selected for deflator in vect.')
    end

else
%    defl = gethaver('dgdp');
end
%defl = lag(defl,-lead);

%Run, using conversion selection
switch size(varargin,2)
    case {1,2,3}    
        %Make that an annualized percentage
        if strcmp(varargin{1},'%-real')
            [debut fin] = findEnds(data,dateRange);
            [start finish] = findEnds (defl,dateRange);
            result = 100*(data.dat(:,debut-1:fin)./defl.dat(:,start-1:finish));
            %Find percent
            result= pct(result,1,4)';
           
        elseif strcmp(varargin{1}, '%')
            data = pctchange(data,1);
            data.dat = 100*((((data.dat./100)+1).^4)-1);
            [debut fin ] = findEnds (data,dateRange);       %get gdp_defl end indexes
            result = data.dat(:,debut: fin)';

        elseif strcmp(varargin{1},'log-real')
            [debut fin] = findEnds(data,dateRange);
            [start finish] = findEnds (defl,dateRange);
            result = log(100*(data.dat(:,debut:fin)./defl.dat(:,start:finish)))';

        elseif strcmp(varargin{1}, 'log')
            
            [debut fin] = findEnds(data,dateRange);
            result = log(data.dat(:,debut:fin))';
                    
        elseif strcmp(varargin{1}, 'log-chg')
            dateRange(1) = index(dateRange(1),-1, data.freq);
            [debut fin] = findEnds(data,dateRange);
            result = log(data.dat(:,debut:fin))';
            result = result(2:end)-result(1:end-1);
               
        elseif strcmp(varargin{1}, 'chg')
            dateRange(1) = index(dateRange(1),-1, data.freq);
            [debut fin] = findEnds(data,dateRange);
            result = (data.dat(:,debut:fin))';
            result = result(2:end)-result(1:end-1);
            
        elseif strcmp(varargin{1},'real')
            [debut fin] = findEnds(data,dateRange);
            [start finish] = findEnds (defl,dateRange);
            result = 100*(data.dat(:,debut:fin)./defl.dat(:,start:finish))';

        else
            error('vect:badConversion', 'Converstion %s is invalid.  Conversion argument may be ''real'', ''log'', ''log-real'', ''%'', or ''%-real.''', upper(varargin{1}) );
        end
    case 0                                  %Do Nothing
        [debut fin ] = findEnds (data,dateRange);       %get gdp_defl end indexes
        result = data.dat(:,debut: fin)';
    otherwise
        error('all:tooManyInputs', 'Too many input arguments in function VECT.');
end


