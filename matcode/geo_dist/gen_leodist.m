clc;
clear;
rover_pos = [-2176839.774457 4387522.359488 4071999.060430];
llh = [39.9289,116.388,100]
% sat_pos1 = [-21699118.836 14920656.435 -1869919.303 -108866.381
%     -21697534.460  14907103.663  -1964707.913  -108866.745
%     -21695690.556  14893324.001  -2059458.198  -108867.110
%     -21693588.044  14879316.450  -2154168.301  -108867.475
%     -21691227.856  14865080.019  -2248836.362  -108867.841
%     -21688610.932  14850613.723  -2343460.526  -108868.208
%     -21685738.218  14835916.586  -2438038.933  -108868.575
%     -21682610.669  14820987.641  -2532569.726  -108868.943
%     -21679229.251  14805825.927  -2627051.048  -108869.313
%     -21675594.933  14790430.491  -2721481.042  -108869.683
%     -21671708.697  14774800.389  -2815857.848  -108870.053
%     ];
% sat_pos2 = [-17765800.643   6503691.035  18599960.207     736.575
%     -17828819.372   6469783.662  18552332.232      736.589
%     -17891728.957   6436058.476  18504347.868      736.603
%     -17954527.718   6402515.491  18456008.064      736.617   
%     ];


load leodata.mat leo_sat;
sat2 = squeeze(leo_sat(1,:,:));
sat5 = squeeze(leo_sat(2,:,:));
sat13 = squeeze(leo_sat(3,:,:));
sat15 = squeeze(leo_sat(4,:,:));
sat21 = squeeze(leo_sat(5,:,:));
sat29 = squeeze(leo_sat(6,:,:));
sat30 = squeeze(leo_sat(7,:,:));
L = length(sat2);
sat2 = [sat2,2*ones(L,1)];
sat5 = [sat5,5*ones(L,1)];
sat13 = [sat13,13*ones(L,1)];
sat15 = [sat15,15*ones(L,1)];
sat21 = [sat21,21*ones(L,1)];
sat29 = [sat29,29*ones(L,1)];
sat30 = [sat30,30*ones(L,1)];
leosat = [sat2';sat5';sat13';sat15';sat21';sat29';sat30'];
save leosatdat.mat leosat;


FREQ1 = 1.57542E9;          %L1/E1/B1C  frequency (Hz) 
FREQ2 = 1.22760E9;          %L2         frequency (Hz) 
C = (FREQ1/FREQ2)^2;
CLIGHT = 299792458.0;       %speed of light (m/s) 
REL_HUMI = 0.7;            % relative humidity for saastamoinen model
ERR_SAAS = 0.3;            % saastamoinen model error std (m) 
ion_default = [
    7.4506D-09 -1.4901D-08 -5.9605D-08  1.1921D-07 ...
    9.0112D+04 -6.5536D+04 -1.3107D+05  4.5875D+05
    ];
pr1s = zeros(7,1);
pr2s = zeros(7,1);
L1s = zeros(7,1);
L2s = zeros(7,1);
P1 = [];
P2 = [];
L1 = [];
L2 = [];

for i = 1:L
rec_clk = normrnd(100,0.01)./1e9;
for j =  1:7
switch j
    case 1
        satpos = sat2(:,1:3);
        satclk = sat2(:,4);
    case 2
        satpos = sat5(:,1:3);
        satclk = sat5(:,4);
    case 3
        satpos = sat13(:,1:3);
        satclk = sat13(:,4);
    case 4
        satpos = sat15(:,1:3);
        satclk = sat15(:,4);
    case 5
        satpos = sat21(:,1:3);
        satclk = sat21(:,4);
    case 6
        satpos = sat29(:,1:3);
        satclk = sat29(:,4);  
    case 7
        satpos = sat30(:,1:3);
        satclk = sat30(:,4);  
end
sat_pos = normrnd(satpos(i,:),0.02);
sat_clk = normrnd(satclk(i),0.001)./1e9;
% sat_clk=0;
gpst0 = [2019,1,10,0,10,0]; %/* gps time reference */
time = epoch2time(gpst0(1),gpst0(2),gpst0(3),gpst0(4),gpst0(5),gpst0(6)+30*i);

r_s = sat_pos - rover_pos;
r = norm(r_s);
e = r_s./r;
pos = ecef2pos(rover_pos);
azel = satazel(pos, e);

dtrp = tropmodel(time, pos, azel, REL_HUMI);
dtrp = normrnd( dtrp, ERR_SAAS);
[dion,var] = ionmodel(time, ion_default, pos, azel);
dion = normrnd( dion, var);

pr1s(j) = r + CLIGHT*(rec_clk - sat_clk) +  dtrp + dion;
pr2s(j) = r + CLIGHT*(rec_clk - sat_clk) + dtrp + C*dion;
L1s(j) = (pr1s(j)-2*dion)*FREQ1/CLIGHT;
L2s(j) = (pr2s(j)-2*C*dion)*FREQ2/CLIGHT;
end
P1 = [P1,pr1s];
P2 = [P2,pr2s];
L1 = [L1,L1s];
L2 = [L2,L2s];
end
P1 = normrnd(P1,0.03);
P2 = normrnd(P2,0.03);
L1 = normrnd(L1,0.1);
L2 = normrnd(L2,0.11);
% AMB1 = mvnrnd(0,10,7);
% AMB2 = mvnrnd(0,10,7);
% L1 = L1 + AMB1;
% L2 = L2 + AMB2;
save measleo.mat P1 P2 L1 L2;
% save amb.mat AMB1 AMB2;
% fp1 = fopen('gpsP11.txt','w');
% for i=1:7
%     fprintf(fp1,'%-20.8f',P1(i,:));
%     fprintf(fp1,'\r\n');
% end
% fclose(fp1);
% fp1 = fopen('gpsP12.txt','w');
% for i=1:7
%     fprintf(fp1,'%-20.8f',P2(i,:));
%     fprintf(fp1,'\r\n');
% end
% fclose(fp1);
% fp1 = fopen('gpsL11.txt','w');
% for i=1:7
%     fprintf(fp1,'%-20.8f',L1(i,:));
%     fprintf(fp1,'\r\n');
% end
% fclose(fp1);
% fp1 = fopen('gpsL12.txt','w');
% for i=1:7
%     fprintf(fp1,'%-20.8f',L2(i,:));
%     fprintf(fp1,'\r\n');
% end
% fclose(fp1);
% save D:\mycode\matcode\geo_dist\gpsP1.txt -ascii P1;
% save D:\mycode\matcode\geo_dist\gpsP2.txt -ascii P2;
% save D:\mycode\matcode\geo_dist\gpsL1.txt -ascii L1;
% save D:\mycode\matcode\geo_dist\gpsL2.txt -ascii L2;

function pos = ecef2pos(rs)
    FE_WGS84 = 1.0/298.257223563;
    RE_WGS84 = 6378137.0;
    e2 = FE_WGS84.*(2.0-FE_WGS84);
    r2 = sum(rs(1:2).*rs(1:2));
    v = RE_WGS84;
    z = rs(3);
    zk = 0.0;
    while abs(z-zk)>=1E-4     
        zk = z;
        sinp = z./sqrt(r2+z.*z);
        v  =RE_WGS84./sqrt(1.0-e2.*sinp.*sinp);
        z = rs(3)+v.*e2.*sinp;
    end
    if r2>1E-12
    pos(1) = atan(z/sqrt(r2));
    pos(2) = atan2(rs(2),rs(1));
    else
        if rs(3)>0.0
        pos(1) = pi/2.0;
        else
        pos(1) = -pi/2.0;
        end
        pos(2) = 0.0;
    end
        pos(3) = sqrt(r2+z.*z)-v;
end

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
    azel = [az,abs(el)];
end

function enu = ecef2enu(pos, r)
    
    E = xyz2enu(pos);
    Et = reshape(E,3,3);
    enu = Et*r';
end

function E = xyz2enu(pos)
    sinp=sin(pos(1));
    cosp=cos(pos(1));
    sinl=sin(pos(2));
    cosl=cos(pos(2));
    
    E(1)=-sinl;      E(4)=cosl;       E(7)=0.0;
    E(2)=-sinp*cosl; E(5)=-sinp*sinl; E(8)=cosp;
    E(3)=cosp*cosl;  E(6)=cosp*sinl;  E(9)=sinp;
end