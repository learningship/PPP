clc;
clear;
load dyna_roverpos.mat dyna_roverpos;
 %rover_pos=[-2173831.7072  4381459.4593  4093731.0168];%πÃ∂®Œª÷√
 rover_pos = dyna_roverpos;
ii=1;
fp = fopen('sol_data2781.txt','r');
while 1
    tline = fgets(fp);   
    if strncmp(tline,"EOF",3)
        break;
    end
        sol(1,ii) = str2double(tline(1:14));
        sol(2,ii) = str2double(tline(17:30));
        sol(3,ii) = str2double(tline(33:46));
                    ii=ii+1;
end
fclose(fp);
L=length(sol);
% for i = 1:L
%     rover_pos(:,i)=(rover_pos(:,i)+rover_pos(:,i+1))/2;
% end
for i = 1:L
    r_r(i,:) = sol(1:3,i) - rover_pos(:,i);
    rec_pos = ecef2pos(rover_pos(:,i));
    enu(i,:) = ecef2enu(rec_pos,r_r(i,:));
end
val=enu(500:700,:);
var=sum((val-mean(val)).^2)/length(val);
figure;
plot(1:L,sol(1,:)-rover_pos(1,1:L),1:L,sol(2,:)-rover_pos(2,1:L),1:L,sol(3,:)-rover_pos(3,1:L));
legend('X','Y','Z');
figure;
plot(1:L,enu);
legend('E','N','U');