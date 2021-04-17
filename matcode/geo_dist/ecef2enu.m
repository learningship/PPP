function enu = ecef2enu(pos, r)
    
    E = xyz2enu(pos);
    Et = reshape(E,3,3);
    enu = Et*r';
end
