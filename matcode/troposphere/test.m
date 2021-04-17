REL_HUMI = 0.7;            % relative humidity for saastamoinen model
ERR_SAAS = 0.3;            % saastamoinen model error std (m) 

pos = [39, 100, 10];
azel = [0, pi/2];
dtrp = tropmodel(time, pos, azel, REL_HUMI);
var = ERR_SAAS.^2;