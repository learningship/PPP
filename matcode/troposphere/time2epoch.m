function [year, month, day, hour, min, sec] = time2epoch(time)
%UNTITLED7 此处显示有关此函数的摘要
%   此处显示详细说明
% /* time to calendar day/time ---------------------------------------------------
% * convert gtime_t struct to calendar day/time
% * args   : gtime_t t        I   gtime_t struct
% *          double *ep       O   day/time {year,month,day,hour,min,sec}
% * return : none
% * notes  : proper in 1970-2037 or 1970-2099 (64bit time_t)
% *-----------------------------------------------------------------------------*/
%      of days in a month
    mday =[
        31 28 31 30 31 30 31 31 30 31 30 31 31 28 31 30 31 30 31 31 30 31 30 31 ...
        31 29 31 30 31 30 31 31 30 31 30 31 31 28 31 30 31 30 31 31 30 31 30 31
    ];
    
%    /* leap year if year%4==0 in 1901-2099 */
days=floor(time/86400);
sec=floor(time-days*86400);
day=rem(days,1461);
for mon=1:48
    if(day>=mday(mon))
        day=day-mday(mon);
    else
        break;
    end
end
year  = 1970+floor(days/1461)*4 + floor((mon-1)/12);
month = rem(mon-1,12)+1;
day   = day+1;
hour  = floor(sec/3600);
min   = floor(rem(sec,3600)/60);
sec   = rem(time-days*86400,60);
end

