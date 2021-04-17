clc;
clear;
%rover_pos0=[-2173831.7072  4381459.4593  4093731.0168];
%%位置39.9289,  116.388 ,10000 高度一万米 速度
rover_pos0=[-2180213.9008314456 4394323.0689768801 4078353.2418611711];
dyna_roverpos(:,1)=rover_pos0';
recVel = 278;
recAcc = 0;
recJerk = 0;
dis = 0;
L=851;
NN=1:L+1;
for i=1:L
dt = 0.2;
recAcc = recAcc + recJerk*dt;
recVel = recVel + recAcc*dt;
distance = recVel*dt;
E = distance;
N = 0;
U = 0;
dis = dis + distance;
ref_pos=dyna_roverpos(:,i);
pos = ecef2pos(ref_pos);
ecef = enu2ecef(pos,[E N U]);
dyna_roverpos(:,i+1) = ref_pos + ecef;
end
plot(NN,dyna_roverpos(1,:)-rover_pos0(1),NN,dyna_roverpos(2,:)-rover_pos0(2),NN,dyna_roverpos(3,:)-rover_pos0(3));
title('1000km/h');
legend('X','Y','Z');
save dyna_roverpos.mat dyna_roverpos