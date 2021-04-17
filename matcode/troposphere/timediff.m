function sec = timediff(t1, t2)
%UNTITLED9 此处显示有关此函数的摘要
%   此处显示详细说明

%difference between gtime_t structrues (t1-t2)
%
%t = timeadd(t, sec)
%
%   Inputs:
%       t1             - gtime_t structrue
%       t2             - gtime_t structrue
%
%   Outputs:
%       sec            - time difference (t1-t2) (s)

t = t1 - t2;
sec = t(1)+t(2);
end

