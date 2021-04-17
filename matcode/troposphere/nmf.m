function [m_h, m_w] = nmf(time, pos, azel,mapfw)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明

     coef = [
         1.2769934E-3 1.2683230E-3 1.2465397E-3 1.2196049E-3 1.2045996E-3
         2.9153695E-3 2.9152299E-3 2.9288445E-3 2.9022565E-3 2.9024912E-3
         62.610505E-3 62.837393E-3 63.721774E-3 63.824265E-3 64.258455E-3
        
         0.0000000E-0 1.2709626E-5 2.6523662E-5 3.4000452E-5 4.1202191E-5
         0.0000000E-0 2.1414979E-5 3.0160779E-5 7.2562722E-5 11.723375E-5
         0.0000000E-0 9.0128400E-5 4.3497037E-5 84.795348E-5 170.37206E-5
        
         5.8021897E-4 5.6794847E-4 5.8118019E-4 5.9727542E-4 6.1641693E-4
         1.4275268E-3 1.5138625E-3 1.4572752E-3 1.5007428E-3 1.7599082E-3
         4.3472961E-2 4.6729510E-2 4.3908931E-2 4.4626982E-2 5.4736038E-2 ];
%  height correction 
    aht = [ 2.53E-5 5.49E-3 1.14E-3]; 
    
    R2D = 180.0/pi;
    ah = zeros(1, 3);
    aw = zeros(1, 3);
    el = azel(2);
    lat = pos(1).*R2D;
    hgt=pos(3);

    
    if el<=0.0
        if mapfw 
            m_w = 0.0;
        end
        m_h = 0.0;
    end
    
%     /* year from doy 28, added half a year for southern latitudes */
    if lat < 0.0
        lat = 0.5;
    else
        lat = 0.0;
        
    y = (time2doy(time)-28.0)/365.25+lat;
    end
    
    cosy = cos(2.0*pi*y);
    lat = abs(lat);

    for i = 1:3
        ah(i)=interpc(coef(i),lat) - interpc(coef(i+3),lat)*cosy;
        aw(i)=interpc(coef(i+6),lat);
    end
%      ellipsoidal height is used instead of height above sea level 
    dm = (1.0/sin(el)-mapf(el,aht(1),aht(2),aht(3)))*hgt/1E3;
    
    if mapfw 
        m_w = mapf(el,aw(1),aw(2),aw(3));
    end
    
   m_h = mapf(el,ah(1),ah(2),ah(3))+dm;

end

