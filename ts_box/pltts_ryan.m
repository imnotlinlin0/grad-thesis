function out =  pltts(tsrange, title, varargin)

% Syntax: pltts(tsrange,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10)
% Plot a bunch of timeseries against the time axis
% Return handle pltts figure.
linetyp = namelist('(blk-)','(blk--)','(r-)','(r--)','(b-)','(b--)','(g-)','(g--)','(c-)','(c--)','(r.)','(b.)');
ltyp1 = 'k-';
ltyp2 = 'k--';
ltyp3 = 'r-';
ltyp4 = 'r--';
ltyp5 = 'b-';
ltyp6 = 'b--';
ltyp7 = 'g-';
ltyp8 = 'g--';
ltyp9 = 'c-';
ltyp10= 'c--';
ltyp11= 'r.';
ltyp12= 'b.';

allflg = strcmp(tsrange,'all');

pltexpr = ' ';
blnknam = setstr(32*ones(1,24));  % ascii for a blank name
tsname = ' ';

minsd = 1e20;
maxed = 0;
maxnobs = 0;
err = 0;
col = [.9 .9 .9];% Default gray for recession bars

nv = length(varargin);

recflg = 0;
vcount = 1;
vloc = [];
for ii = 1:nv

	if(tschk(varargin{ii}))
		eval(['v',num2str(vcount),'=varargin{ii};'])
		vcount = vcount+1;
		vloc  = [vloc,ii+1];
	elseif(isstr(varargin{ii})&recflg==0)
		eval(['ltyp',num2str(vcount-1),'=varargin{ii};'])
	elseif(isstr(varargin{ii})&recflg==1)
		col = varargin{ii};
	elseif(varargin{ii}==1)
		recflg = 1;
	end
		
end
vcount = vcount - 1;
if(vcount==0)
	error('We''re plotting timeseries here, OK?')
end
freq = Get_Freq_ts(v1);

for jj = 1:vcount
   temp = eval(['v',int2str(jj)]);
   %tname = padname(Get_Name_ts(temp),24);
   tname = padname(varargin{jj}.name,24);
   if(strcmp(blnknam,tname)) tname(1:3) = '???';end
   linenam = ['(',eval(['ltyp',int2str(jj)]),') '];
   tsname = [tsname,linenam,tname];
   if(~allflg)
        [temp,err] = tsproject(temp,tsrange(1),tsrange(2));  % tsproject over tsrange
   else
	tempsd = Get_Start_ts(temp);
	temped = Get_End_ts(temp);
	eval(['tsi',int2str(jj),'=pltax(tempsd,temped,freq);'])
	if(tempsd<minsd) minsd = tempsd; end
	if(temped>maxed) maxed = temped; end
   end
   if(err~=0)
        error(['Exiting pltts.  Incorrect tsrange for variable ',num2str(jj)])
   end
   temp = Get_Data_ts(temp);           % Use only data part if it's a timeseries
   temp = temp';

   if(length(temp)>maxnobs) maxnobs = length(temp); end
   expr = ['x',num2str(jj),' = temp;'];
   eval(expr);
   if(allflg)
	if(jj==1)  pltexpr = [pltexpr,'tsi',int2str(jj),',x',int2str(jj),',ltyp',num2str(jj)];end
	if(jj>1)   pltexpr = [pltexpr,',tsi',int2str(jj),',x',int2str(jj),',ltyp',num2str(jj)];end
   else
	if(jj==1)  pltexpr = [pltexpr,'tsi',',x',int2str(jj),',ltyp',num2str(jj)];end
	if(jj>1)   pltexpr = [pltexpr,',tsi',',x',int2str(jj),',ltyp',num2str(jj)];end
   end
end

if(allflg)
	nobs = length(x1);
	tsrange = [minsd,maxed];
else
	nobs = maxnobs;
end

if(~allflg)
	tsi = pltax(tsrange(1),tsrange(2),freq);
end

if(recflg)
	[pos,han] = recess2(tsrange,freq,col);
	axes('position',pos);
end

pltexpr = ['plot(',pltexpr,')'];

eval(pltexpr)
set(gca,'color','none');
if(recflg) set(han,'xlim',get(gca,'xlim'));end
if(freq==1) freqword = 'Annual';end
if(freq==4) freqword = 'Quarterly';end
if(freq==12) freqword = 'Monthly';end
%title([freqword,' data from ',printdate(tsrange(1),freq),' to ',printdate(tsrange(2),freq)]);
h = xlabel(tsname);

colorfig('w')
thicklines(2)
mtit(title);

out = get(get(h, 'Parent'),'Parent');


