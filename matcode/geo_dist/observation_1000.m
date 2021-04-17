load measleo.mat P1 P2 L1 L2;
a = 6378137; %
f = 1/298.257223563; % 
Omega_e_dot = 7.2921151467e-5; % 
mu = 3.986005e14; % 
c = 2.99792458e8; % 

% 
phi = 39.969949;
lamda = 116.365785;
h = 0;
N = a / sqrt(1 - f^2 / sin(phi)^2);
x = (N + h) * cos(phi) * cos(lamda);
y = (N + h) * cos(phi) * sin(lamda);
z = (N * (1 - f^2) + h) * sin(phi);

file = fopen('D:\mycode\matcode\geo_distobservationLEO.obs', 'w');
fprintf(file, '     3.02           OBSERVATION DATA    M: Mixed            RINEX VERSION / TYPE\n');
fprintf(file, 'BUPT PLAN 6.0                           20210329 120000 UTC PGM / RUN BY / DATE \n');
fprintf(file, '                                                            MARKER NAME         \n');
fprintf(file, '                                                            MARKER NUMBER       \n');
fprintf(file, '                                                            MARKER TYPE         \n');
fprintf(file, '                                                            OBSERVER / AGENCY   \n');
fprintf(file, '                                                            REC # / TYPE / VERS \n');
fprintf(file, '                                                            ANT # / TYPE        \n');
fprintf(file, '%14.4f%14.4f%14.4f                  APPROX POSITION XYZ \n', x, y, z);
fprintf(file, '        0.0000        0.0000        0.0000                  ANTENNA: DELTA H/E/N\n');
fprintf(file, 'G   64 C1C L1C D1C C2P L2P D2P S1C S1P C1W L1W D1W S1W C1Y  SYS / # / OBS TYPES \n');
fprintf(file, '       L1Y D1Y S1Y C1M L1M D1M S1M L1N D1N S1N C1S L1S D1S  SYS / # / OBS TYPES \n');
fprintf(file, '       S1S C1L L1L D1L S1L C2C L2C D2C S2C C2D L2D D2D S2D  SYS / # / OBS TYPES \n');
fprintf(file, '       C2S L2S D2S S2S C2L L2L D2L S2L C2X L2X D2X S2X C2P  SYS / # / OBS TYPES \n');
fprintf(file, '       L2P D2P S2P C2W L2W D2W S2W C2Y L2Y D2Y S2Y C2M      SYS / # / OBS TYPES \n');
fprintf(file, 'C    3 C1I L1I D1I                                          SYS / # / OBS TYPES \n');
fprintf(file, '  2019     1    10    10     0    0.0000000     GPS         TIME OF FIRST OBS   \n');
fprintf(file, '  2019     1    10    10     5    0.0000000     GPS         TIME OF FIRST OBS   \n');
fprintf(file, '                                                            END OF HEADER       \n');

% 2019 1 10 10:00 0.000000  2019 1 10 10:04 59.00000
for i = 1 : 300    
    t = i - 1 + P1(1,i)/c;
%    fprintf(file, '> 2019  1 10   9 %2d  %.8f  0 7                     ', floor(mod(t,60)), abs(t-floor(mod(t,60))));  
    fprintf(file, '> 2019  1 10 10 %2d %10.7f  0 7                     ', floor(t/60), mod(t,60));
    fprintf(file,'\n');
    for j = 1 : 7
        prn = 'G 8G 9G10G11G12G13G14';
        fprintf(file, '%s%14.3f%16.3f%16.3f%s%16.3f%16.3f%16.3f%s%16.3f%16.3f\n', prn(1+3*(j-1):3*j), P1(j,i), L1(j,i), 0, 0, P2(j,i), L2(j,i), 0, 0);
        fprintf(file,'\n');
    end
end
fclose(file);
