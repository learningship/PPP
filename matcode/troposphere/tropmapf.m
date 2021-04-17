function [m_h, m_w] = tropmapf(time, pos, azel, mapfw)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
% /* troposphere mapping function ------------------------------------------------
% * compute tropospheric mapping function by NMF
% * args   : gtime_t t        I   time
% *          double *pos      I   receiver position {lat,lon,h} (rad,m)
% *          double *azel     I   azimuth/elevation angle {az,el} (rad)
% *          double *mapfw    IO  wet mapping function (NULL: not output)
% * return : dry mapping function
% * note   : see ref [5] (NMF) and [9] (GMF)
% *          original JGR paper of [5] has bugs in eq.(4) and (5). the corrected
% *          paper is obtained from:
% *          ftp://web.haystack.edu/pub/aen/nmf/NMF_JGR.pdf
% *-----------------------------------------------------------------------------*/
    if pos(3)<-1000.0||pos(3)>20000.0
        if mapfw 
            m_w=0.0;
        end
        m_h = 0.0;
    end
        
    
    [m_h, m_w] = nmf(time,pos,azel,mapfw); 


end

