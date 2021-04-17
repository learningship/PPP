function azel = satazel(pos, e)
    RE_WGS84 = 6378137.0;
    az = 0.0;
    el = pi/2.0;
    
    if pos(3)>-RE_WGS84 
        enu = ecef2enu(pos,e);
        az = enu.*enu;
        if az<1E-12
            az = 0.0;
        else
            az = atan2(enu(1),enu(2));
        end
        if az<0.0 
            az = az + 2*pi;
        end
        el=asin(enu(3));
    end
    azel = [az,el];
end

