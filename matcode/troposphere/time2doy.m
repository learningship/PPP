function doy = time2doy(t)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
 
    [year, month, day, hour, min, sec] = time2epoch(t);
    mon = 1.0;day = 1.0; hour = 0.0;min = 0.0;sec = 0.0;
    doy = timediff(t,epoch2time(year,month,day,hour,min,sec))/86400.0+1.0;


end

