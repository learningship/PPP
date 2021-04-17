clc;
clear;
load measleo.mat P1 P2 L1 L2;
load leostapos.mat sat;
rover_pos = [-2176839.774457 4387522.359488 4071999.060430];
% rover_pos = [-2176805.6923727235 4387453.6654526051 4071934.8767794245];
rover_pos=[-2173831.7072  4381459.4593  4093731.0168];
FREQ1 = 5.02E9;          %L1/E1/B1C  frequency (Hz) 
FREQ2 = 7.07E9;          %L2         frequency (Hz) 
OMGE = 7.2921151467E-5;
ERR_SAAS = 0.3;
vart = ERR_SAAS^2;
CLIGHT = 299792458.0;       %speed of light (m/s) 
C1 = FREQ1^2/(FREQ1^2-FREQ2^2);
C2 = -FREQ2^2/(FREQ1^2-FREQ2^2);
Pc = C1*P1 + C2*P2;
Lc = C1*L1*CLIGHT/FREQ1 + C2*L2*CLIGHT/FREQ2;
L = length(Lc);
F1=1;
H1=0;
Q1=0.1;
R1=zeros(14,16);
var = zeros(1,16);
v1 = zeros(1,8);
var1 = zeros(1,8);
x = zeros(1,4);
 x = [-2176830 4387520 4071990 0];
gpst0 = [2019,1,10,9,50,0]; %/* gps time reference */
ion_default = [
    7.4506D-09 -1.4901D-08 -5.9605D-08  1.1921D-07 ...
    9.0112D+04 -6.5536D+04 -1.3107D+05  4.5875D+05
    ];


%Xplus1(1)~N(0.01,0.01^2)

Xplus1(1,1:4)=[-2173830  4381455  4093730 0];
 Xplus1(1,5:12)=Lc(1)-Pc(1);
Pplus1=1*eye(12);
V=zeros(2*8,L);
% x = [-2176839.774457 4387522.359488 4071999.060430 300];
%%%
%X(K)minus=F*X(K-1)plus
%P(K)minus=F*P(K-1)plus*F'+Q
%K=P(K)minus*H'*inv(H*P(K)minus*H'+R)
%X(K)plus=X(K)minus+K*(y(k)-H*X(K)minus)
%P(K)plus=(1-K*H)*P(K)minus
for i=2:L
    time = epoch2time(gpst0(1),gpst0(2),gpst0(3),gpst0(4),gpst0(5),gpst0(6)+30*(i));
    for iter = 1:12
    e01 = [];
    for s = 1:8
    sat_pos = sat(1+4*(s-1):3+4*(s-1),i)';
    t = -P1(s,i)/CLIGHT;
    sinl=sin(OMGE*t);
    cosl=cos(OMGE*t);
    sat_pos(1)=cosl*sat_pos(1)-sinl*sat_pos(2);
    sat_pos(2)=sinl*sat_pos(1)+cosl*sat_pos(2);
    sat_pos(3)=sat_pos(3);
    sat_clk = sat(4*s,i)./1e9;
    cdtr=x(4);
    cdts = CLIGHT*sat_clk;
%           x(1:3)=rover_pos;
    r_s = sat_pos - x(1:3);
    r = norm(r_s);
    e11 = r_s./r;
    e01 = [e01;e11];
    pos = ecef2pos(x(1:3));
    azel = satazel(pos, e11);
    [dion,vari] = ionmodel(time, ion_default, pos, azel);
    dtrp = tropmodel(0, pos, azel, 0.7);
    vart = ERR_SAAS^2;
%     dion=0;
%     dtrp=0;
    v1(s) = P1(s,i) - (r + cdtr-cdts + dion + dtrp);
    var1(s) = ((300*0.003)^2+(300*0.003/sin(azel(2)))^2)+vart+vari;
    end
      H = [e01,-ones(s,1)];
   %  H = e01;
    for s = 1:8
        sig = sqrt(var1(s));
        v1(s) = v1(s)/sig;
        H(s,:) = H(s,:)/sig;
    end
    dx = inv(H'*H)*H'*v1';
    x = x - dx';
    if norm(dx) < 1e-4
        X(i,:) = x;
        break;
    end
    end
    
%     %%%
%      Xplus1(1,1:4) = X(2,:);
%     Xplus1(1,1:4) = X(2,:);
    Xminus1=Xplus1(i-1,:);
%      Xminus1(4) = X(i,4);
    Pminus1=Pplus1+blkdiag(1e-6*eye(3),1e-2,1e-2*eye(8));
    var1 = var;
    e2 = [];
    Ha = eye(8);
    
    for s = 1:8
    sat_pos = sat(1+4*(s-1):3+4*(s-1),i)';
    t = -P1(s,i)/CLIGHT;
    sinl=sin(OMGE*t);
    cosl=cos(OMGE*t);
    sat_pos(1)=cosl*sat_pos(1)-sinl*sat_pos(2);
    sat_pos(2)=sinl*sat_pos(1)+cosl*sat_pos(2);
    sat_pos(3)=sat_pos(3);
    sat_clk = sat(4*s,i)./1e9;
    cdtr =Xminus1(4);
    cdts = CLIGHT*sat_clk;
    r_s = sat_pos - Xminus1(1:3);
    r = norm(r_s);
    e1 = r_s./r;
    pos = ecef2pos(Xminus1(1:3));
    azel = satazel(pos, e1);
    dtrp = tropmodel(0, pos, azel, 0.7);
%      dion=0;
%      dtrp=0;
    for j = 1:2
    if j == 1
        y = Lc(s,i)-Xminus1(4+s);
        fact = 0.03;
    else
        y = Pc(s,i);
        fact = 0.03;
    end
    %%%更新�?%%

    v(j+2*(s-1)) = y - (r+cdtr-cdts+dtrp);    
    var(j+2*(s-1)) = ((fact*0.003)^2+(fact*0.003/sin(azel(2)))^2)+vart+0.8*var1(2*s-1);
var(j+2*(s-1)) = 1;
    end

    e2 = [e2;e1;e1];
    Ha = [Ha(1:2*s-1,:);zeros(1,8);Ha(2*s:end,:)];
    end
    V(:,i)=v;
    R1 = diag(var);
    H1 = [e2, -ones(2*s,1),-Ha];
%     H1 = [e2, -ones(2*s,1)];
    K=(Pminus1*H1')*inv(H1*Pminus1*H1'+R1);
    Xplus1(i,:)=Xminus1-(K*v')';
    Pplus1=(eye(12)-K*H1)*Pminus1;
    
end
figure(1)
plot(1:L,Xplus1(:,1)-rover_pos(1),1:L,Xplus1(:,2)-rover_pos(2),1:L,Xplus1(:,3)-rover_pos(3));
legend('X','Y','Z');
% plot(1:L,Xplus1(:,1)-mean(Xplus1(:,1)),1:L,Xplus1(:,2)-mean(Xplus1(:,2)),1:L,Xplus1(:,3)-mean(Xplus1(:,3)));
% plot(2:L,X(2:L,1)-rover_pos(1),2:L,X(2:L,2)-rover_pos(2),2:L,X(2:L,3)-rover_pos(3));
%plot(1:L,X(1:L,1)-rover_pos(1),1:L,X(1:L,2)-rover_pos(2),1:L,X(1:L,3)-rover_pos(3));
% legend('X','Y','Z');
for i = 1:L
    r_r(i,:) = Xplus1(i,1:3) - rover_pos;
    rec_pos = ecef2pos(rover_pos);
    enu(i,:) = ecef2enu(rec_pos,r_r(i,:));
end
figure(2);
plot(1:L,enu);
legend('E','N','U');
figure(3);
plot(2:L,V(:,2:L));