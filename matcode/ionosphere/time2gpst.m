function [tow,ws] = time2gpst( time, week)
%UNTITLED17 此处显示有关此函数的摘要
%   此处显示详细说明
% /* time to gps time ------------------------------------------------------------
% * convert gtime_t struct to week and tow in gps time
% * args   : gtime_t t        I   gtime_t struct
% *          int    *week     IO  week number in gps time (NULL: no output)
% * return : time of week in gps time (s)
% *-----------------------------------------------------------------------------*/
    gpst0 = [1980,1, 6,0,0,0]; %/* gps time reference */
    t0 = epoch2time(gpst0(1),gpst0(2),gpst0(3),gpst0(4),gpst0(5),gpst0(6));
    sec = time - t0;
    w = floor(sec/(86400*7));
    
    if week
        ws = w;
    end
    tow = sec - w*86400*7;
end

