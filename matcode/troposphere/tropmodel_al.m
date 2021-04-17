function dtrp = tropmodel( time, pos, azel, humi)
%UNTITLED12 此处显示有关此函数的摘要
%   此处显示详细说明
% /* troposphere model -----------------------------------------------------------
% * compute tropospheric delay by standard atmosphere and saastamoinen model
% * args   : gtime_t time     I   time
% *          double *pos      I   receiver position {lat,lon,h} (rad,m)
% *          double *azel     I   azimuth/elevation angle {az,el} (rad)
% *          double humi      I   relative humidity
% * return : tropospheric delay (m)

    const double temp0=15.0; /* temparature at sea level */
    double hgt,pres,temp,e,z,trph,trpw;
    
    if (pos[2]<-100.0||1E4<pos[2]||azel[1]<=0) return 0.0;
    
    /* standard atmosphere */
    hgt=pos[2]<0.0?0.0:pos[2];
    
    pres=1013.25*pow(1.0-2.2557E-5*hgt,5.2568);
    temp=temp0-6.5E-3*hgt+273.16;
    e=6.108*humi*exp((17.15*temp-4684.0)/(temp-38.45));
    
    /* saastamoninen model */
    z=PI/2.0-azel[1];
    trph=0.0022768*pres/(1.0-0.00266*cos(2.0*pos[0])-0.00028*hgt/1E3)/cos(z);
    trpw=0.002277*(1255.0/temp+0.05)*e/cos(z);
    return trph+trpw;

end

