function ecef = enu2ecef(pos, e)
    
    E = xyz2enu(pos);
    Et = reshape(E,3,3);
    ecef = Et*e';
end

