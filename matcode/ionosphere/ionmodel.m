function [dion,var] = ionmodel( t, ion, pos, azel)
%UNTITLED16 此处显示有关此函数的摘要

% /* ionosphere model ------------------------------------------------------------
% * compute ionospheric delay by broadcast ionosphere model (klobuchar model)
% * args   : gtime_t t        I   time (gpst)
% *          double *ion      I   iono model parameters {a0,a1,a2,a3,b0,b1,b2,b3}
% *          double *pos      I   receiver position {lat,lon,h} (rad,m)
% *          double *azel     I   azimuth/elevation angle {az,el} (rad)
% * return : ionospheric delay (L1) (m)
% *-----------------------------------------------------------------------------*/
    CLIGHT = 299792458.0;         % speed of light (m/s) 
    ERR_BRDCI =  0.5;             % broadcast iono model error factor 
    if pos(3)<-1E3||azel(2)<=0 
        dion = 0.0;
    end
%     if (norm(ion,8)<=0.0) ion=ion_default;
    
%     /* earth centered angle (semi-circle) */
    psi=0.0137/(azel(2)/pi+0.11)-0.022;
    
%     /* subionospheric latitude/longitude (semi-circle) */
    phi=pos(1)/pi+psi*cos(azel(1));
    if     phi > 0.416
           phi = 0.416;
    elseif phi < -0.416
           phi = -0.416;
    end
    lam = pos(2)/pi+psi*sin(azel(1))/cos(phi*pi);
    
%     /* geomagnetic latitude (semi-circle) */
    phi = phi + 0.064*cos((lam-1.617)*pi);
    
%     /* local time (s) */
    [tow, week] = time2gpst(t,1);
    tt = 43200.0*lam + tow;
    tt = tt - floor(tt/86400.0)*86400.0; %/* 0<=tt<86400 */
    
%     /* slant factor */
    f = 1.0 + 16.0.*(0.53-azel(2)/pi).^3.0;
    
%     /* ionospheric delay */
    amp=ion(1)+phi*(ion(2)+phi*(ion(3)+phi*ion(4)));
    per=ion(5)+phi*(ion(6)+phi*(ion(7)+phi*ion(8)));
    if amp < 0.0
        amp = 0.0;
    end
    if per < 72000.0
        per = 72000.0;
    end
    x = 2.0*pi*(tt-50400.0)/per;
    if abs(x) < 1.57
        x_tem = 5E-9+amp*(1.0+x*x*(-0.5+x*x/24.0));
    else
        x_tem = 5E-9;
    end       
    dion = CLIGHT * f * x_tem.*0.1;
    var = dion.*ERR_BRDCI.*0.1;

end

