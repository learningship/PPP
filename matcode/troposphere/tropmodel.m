function zhd = tropmodel(time, pos, azel, humi)
%tropmodel 天顶对流层延迟
% * compute tropospheric delay by standard atmosphere and saastamoinen model
% * args   : gtime_t time     I   time
% *          double *pos      I   receiver position {lat,lon,h} (rad,m)
% *          double *azel     I   azimuth/elevation angle {az,el} (rad)
% *          double humi      I   relative humidity
% * return : tropospheric delay (m)

% temparature at sea level
    temp0=15.0; 
    
    if (pos(3)<-100.0||1E4<pos(3)||azel(2)<=0)
        zhd = 0;   
    else              
%   standard atmosphere 
    if pos(3) < 0.0
        hgt = 0.0;
    else
        hgt = pos(3);
    end
    pres=1013.25.*(1.0-2.2557E-5*hgt).^5.2568;
    temp=temp0-6.5E-3*hgt+273.16;
    e=6.108*humi*exp((17.15*temp-4684.0)/(temp-38.45));
    
%   saastamoninen model 
    z=pi/2.0-azel(2);
    trph=0.0022768*pres/(1.0-0.00266*cos(2.0*pos(1))-0.00028*hgt/1E3)/cos(z);
    trpw=0.002277*(1255.0/temp+0.05)*e/cos(z);
    zhd = trph+trpw;
    end
end

