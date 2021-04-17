clc;
clear;
% load leotestobs.mat P1 P2 L1 L2;
%  load leostapos.mat sat;%LEO 轨道数据
% load satdat.mat sat;%GPS 轨道数据
load leodata.mat leo_sat;%10min leo
%  rover_pos = [-2176839.774457 4387522.359488 4071999.060430];
%  rover_pos = [-2176805.6923727235 4387453.6654526051 4071934.8767794245];
rover_pos=[-2173831.7072  4381459.4593  4093731.0168];
FREQ1 = 5E9;          %L1/E1/B1C  frequency (Hz) 
FREQ2 = 7E9;          %L2         frequency (Hz) 
CLIGHT = 299792458.0;       %speed of light (m/s) 
% L = length(sat);
L = length(leo_sat);
azel=zeros(14,L);
 satid = ["D3704","D3903","D4003","D4103","D5627","D5727","D5826","D5926"];
%satid = ["G02","G05","G13","G15","G21","G29","G30"];
sat_N = 8;%卫星个数
% for i=1:L
%     for s = 1:sat_N
%     sat_pos = sat(1+4*(s-1):3+4*(s-1),i)';
%     sat_clk = sat(4*s,i)./1e9;
%     x=rover_pos;
%     r_s = sat_pos - x(1:3);
%     r = norm(r_s);
%     e11 = r_s./r;
%     pos = ecef2pos(x(1:3));
%     azel(2*s-1:2*s,i) = satazel(pos, e11);
%     end
% end
for i=1:L
    for s = 1:sat_N
    sat_pos = squeeze(leo_sat(s,i,1:3));
    x=rover_pos;
    r_s = sat_pos - x(1:3);
    r = norm(r_s);
    e11 = r_s./r;
    pos = ecef2pos(x(1:3));
    azel(2*s-1:2*s,i) = satazel(pos, e11);
    end
end

for i=1:L
    for s=1:sat_N
    az(s,i) = azel(2*s-1,i)-pi;
    el(s,i) = azel(2*s,i);
    R(s,i) = 180*el(s,i)/pi;
%     x1(s,i)=R*sin(az);
%     y1(s,i)=R*cos(az);
    end
end
for s=1:sat_N
% % plot(x1(s,:),y1(s,:));
% polarplot(az(s,1),R(s,1),'Marker','o','MarkerFaceColor','auto');
polarplot(az(s,:),R(s,:),'LineWidth',5);
hold on;
polarplot(az(s,1),R(s,1),'Marker','o','MarkerFaceColor','auto','MarkerSize',10);
text(az(s,1),R(s,1),satid(s),'FontSize',8);
hold on;

rlim([0 90])                                         % 设置半径范围
rticks([0 15 30 45 60 75 90])								    % 在r=0.6、1.6、2处显示刻度
% rticklabels({'r = 0.6','r = 1.2','r = 2'})		    % 在刻度线处加标记
pax = gca;
pax.ThetaDir = 'clockwise';		   % 按顺时针方式递增
pax.ThetaZeroLocation = 'top';     % 将0度放在顶部  
% % axis([-90 90 -90 90]);
set(gca,'RDir','reverse')
% % set(gca,'YDir','reverse')
end

for i=1:L
for s=1:sat_N
cosel=cos(el(s,i));
sinel=sin(el(s,i));
H(1,s)=cosel*sin(az(s,i));
H(2,s)=cosel*cos(az(s,i));
H(3,s)=sinel;
H(4,s)=1.0;
end
    Q=inv(H*H');
    GDOP(i)=sqrt(Q(1,1)+Q(2,2)+Q(3,3)+Q(4,4));
    PDOP(i)=sqrt(Q(1,1)+Q(2,2)+Q(3,3));
    HDOP(i)=sqrt(Q(1,1)+Q(2,2));
    VDOP(i)=sqrt(Q(3,3));
end
N=1:L;
figure;
plot(N,GDOP,N,PDOP,N,HDOP,N,VDOP);
legend('GDOP','PDOP','HDOP','VDOP');
% Nt=L;
% for i=1:30:Nt
%     
%     for s=1:8
%     polarplot(az(s,:),R(s,:),'LineWidth',5);
%     hold on;
%     rlim([0 90])                                       
%     rticks([0 15 30 45 60 75 90])							
%     pax = gca;
%     pax.ThetaDir = 'clockwise';		 
%     pax.ThetaZeroLocation = 'top';    
%     set(gca,'RDir','reverse')
%     end
%     for s=1:8
%     polarplot(az(s,i),R(s,i),'Marker','o','MarkerSize',10);
%     text(az(s,1),R(s,1),satid(s),'FontSize',8);
%     end
% 
%     frame=getframe(gcf);
%     imind=frame2im(frame);
%     [imind,cm] = rgb2ind(imind,256);
%     if i==1
%          imwrite(imind,cm,'test.gif','gif', 'Loopcount',inf,'DelayTime',1e-4);
%     else
%          imwrite(imind,cm,'test.gif','gif','WriteMode','append','DelayTime',1e-4);
%     end
% end
% legend(satid);

% r=2; theta=0:pi/100:2*pi;
% 
% x=r*cos(theta); y=r*sin(theta);
% 
% rho=r*sin(theta);
% 
% % figure(1)
% % 
% % plot(x,y,'-')
% % 
% % hold on; axis equal
% % 
% % fill(x,y,'c')
% 
% figure(2)
% 
% h=polar(theta,rho);
% 
% set(h,'LineWidth',2)