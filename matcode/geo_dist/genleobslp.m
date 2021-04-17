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

file = fopen('D:\mycode\matcode\observationLEO1.obs', 'w');
fprintf(file, '     3.02           OBSERVATION DATA    M: Mixed            RINEX VERSION / TYPE\n');
fprintf(file, 'BUPT PLAN 6.0                           20210329 120000 UTC PGM / RUN BY / DATE \n');
fprintf(file, '                                                            MARKER NAME         \n');
fprintf(file, '                                                            MARKER NUMBER       \n');
fprintf(file, '                                                            MARKER TYPE         \n');
fprintf(file, '                                                            OBSERVER / AGENCY   \n');
fprintf(file, '                                                            REC # / TYPE / VERS \n');
fprintf(file, '                                                            ANT # / TYPE        \n');
fprintf(file, '%14.4f%14.4f%14.4f                  APPROX POSITION XYZ \n', x, y, z);
fprintf(file, '        0.0000        0.0000        0.0000                  ANTENNA: DELTA H/E/N \n');
fprintf(file, 'D    6 C5D L5D D5D C7D L7D D7D                              SYS / # / OBS TYPES  \n');
fprintf(file, '    30.000                                                  INTERVAL            \n');
fprintf(file, '  2019     1    10     9    51   54.0000000     GPS         TIME OF FIRST OBS   \n');
fprintf(file, '  2019     1    10     9    54   44.0000000     GPS         TIME OF LAST OBS   \n');
fprintf(file, '                                                            END OF HEADER       \n');

% 2019 1 10 10:00 0.000000  2019 1 10 10:04 59.00000
for i = 1 : 849    
    t = 51*60 + 54 + (i - 1)/5.0;
%    fprintf(file, '> 2019  1 10   9 %2d  %.8f  0 7                     ', floor(mod(t,60)), abs(t-floor(mod(t,60))));  
    fprintf(file, '> 2019  1 10  9 %2d %10.7f  0 8                     ', floor(t/60), mod(t,60));
    fprintf(file,'\n');
    for j = 1 : 8
        prn = 'D3704D3903D4003D4103D5627D5727D5826D5926';
        fprintf(file, '%s%14.3f%16.3f%16.3f%16.3f%16.3f%16.3f%16.3f%16.3f', prn(1+5*(j-1):5*j), P1(j,i), L1(j,i), (L1(j,i)-L1(j,i+1))*5, P2(j,i), L2(j,i),(L2(j,i)-L2(j,i+1))*5);
        %fprintf(file, '%s%14.3f%16.3f%16.3f%16.3f%16.3f%16.3f%16.3f%16.3f', prn(1+5*(j-1):5*j), P1(j,i), L1(j,i), 0, P2(j,i), L2(j,i), 0);
        fprintf(file,'\n');
    end
end
fclose(file);
