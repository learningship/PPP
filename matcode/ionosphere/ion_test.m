%  2019/1/1 
ion_default = [
    7.4506D-09 -1.4901D-08 -5.9605D-08  1.1921D-07 ...
    9.0112D+04 -6.5536D+04 -1.3107D+05  4.5875D+05
    ];
pos = [20, 120, 10];
azel = [0, 0.3];
gpst0 = [2019,1, 9,11,0,0]; %/* gps time reference */
time = epoch2time(gpst0(1),gpst0(2),gpst0(3),gpst0(4),gpst0(5),gpst0(6));
%time = 1.547118e+09;
[dion,var] = ionmodel(time, ion_default, pos, azel);