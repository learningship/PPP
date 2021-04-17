function time = epoch2time(year,month,day,hour,min,sec)
%UNTITLED8 此处显示有关此函数的摘要
%   此处显示详细说明
% convert calendar day/time to time(s) 
doy = [1,32,60,91,121,152,182,213,244,274,305,335];
% leap year if year%4==0 in 1901-2099 
days=(year-1970)*365+floor((year-1969)/4)+doy(month)+day-2;
if(rem(year,4)==0&&month>=3) 
	days=days+1;
end
time=days*86400+hour*3600+min*60+sec;

end

