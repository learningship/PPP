clc;
clear;
load meas.mat P1 P2 L1 L2;
load satdat.mat sat;
rover_pos = [-2148761.8120073779 4426673.0463592755 4044686.6014460167];
FREQ1 = 1.57542E9;          %L1/E1/B1C  frequency (Hz) 
FREQ2 = 1.22760E9;          %L2         frequency (Hz) 
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
R1=zeros(14,14);
var = zeros(1,14);
v1 = zeros(1,7);
var1 = zeros(1,7);
x = zeros(1,4);
%初始化x(k)+
gpst0 = [2019,1,10,0,10,0]; %/* gps time reference */
ion_default = [
    7.4506D-09 -1.4901D-08 -5.9605D-08  1.1921D-07 ...
    9.0112D+04 -6.5536D+04 -1.3107D+05  4.5875D+05
    ];


%设置初�?�，假设Xplus1(1)~N(0.01,0.01^2)
Xplus1(1,1:4)=[-2148760 4426670 4044689 30];
Pplus1=6000*eye(4);

%%%卡尔曼滤波算�?
%X(K)minus=F*X(K-1)plus
%P(K)minus=F*P(K-1)plus*F'+Q
%K=P(K)minus*H'*inv(H*P(K)minus*H'+R)
%X(K)plus=X(K)minus+K*(y(k)-H*X(K)minus)
%P(K)plus=(1-K*H)*P(K)minus
for i=2:L
    %%
    time = epoch2time(gpst0(1),gpst0(2),gpst0(3),gpst0(4),gpst0(5),gpst0(6)+30*(i-1));
    for iter = 1:12
    e01 = [];
    for s = 1:7
    sat_pos = sat(1+4*(s-1):3+4*(s-1),i-1)';
    sat_clk = sat(4*s,i-1)./1e9;
    cdtr = x(4);
    cdts = CLIGHT*sat_clk;
    r_s = sat_pos - x(1:3);
    r = norm(r_s);
    e11 = r_s./r;
    e01 = [e01;e11];
    pos = ecef2pos(x(1:3));
    azel = satazel(pos, e11);
    [dion,vari] = ionmodel(time, ion_default, pos, azel);
    dtrp = tropmodel(0, pos, azel, 0.7);
    vart = ERR_SAAS^2;
    v1(s) = P1(s,i-1) - (r + cdtr-cdts + dion + dtrp);
    var1(s) = ((300*0.003)^2+(300*0.003/sin(azel(2)))^2)+vart+vari;
    end
    H = [e01,-ones(s,1)];
    for s = 1:7
        sig = sqrt(var1(s));
        v1(s) = v1(s)/sig;
        H(s,:) = H(s,:)/sig;
    end
    dx = inv(H'*H)*H'*v1';
    x = x - dx';
    if norm(dx) < 1e-4
        X(i-1,:) = x;
        break;
    end
    end
    
%     %%%预测�?%%
     Xplus1(1,:) = X(1,:);
    Xminus1=Xplus1(i-1,:);
%        Xminus1(4) = X(i,4);
    Pminus1=Pplus1+blkdiag(1e-4*eye(3),10000);
    var1 = var;
    e2 = [];
    for s = 1:7
    sat_pos = sat(1+4*(s-1):3+4*(s-1),i)';
    sat_clk = sat(4*s,i)./1e9;
    cdtr = Xminus1(4);
    cdts = CLIGHT*sat_clk;
    r_s = sat_pos - Xminus1(1:3);
    r = norm(r_s);
    e1 = r_s./r;
    pos = ecef2pos(Xminus1(1:3));
    azel = satazel(pos, e1);
    dtrp = tropmodel(0, pos, azel, 0.7);

    for j = 1:2
    if j == 1
        y = Lc(s,i);
        fact = 3;
    else
        y = Pc(s,i);
        fact = 300;
    end
    %%%更新�?%%

    v(j+2*(s-1)) = y - (r+cdtr-cdts+dtrp);    
    var(j+2*(s-1)) = ((fact*0.003)^2+(fact*0.003/sin(azel(2)))^2)+vart+0.99*var1(2*s-1);
    end
    e2 = [e2;e1;e1];
    end
    R1 = diag(var);
    H1 = [e2, -ones(2*s,1)];
    K=(Pminus1*H1')*inv(H1*Pminus1*H1'+R1);
    Xplus1(i,:)=Xminus1-(K*v')';
    Pplus1=(eye(4)-K*H1)*Pminus1;
    
end
figure(1);
plot(1:L,Xplus1(:,1)-rover_pos(1),1:L,Xplus1(:,2)-rover_pos(2),1:L,Xplus1(:,3)-rover_pos(3));
legend('X','Y','Z');
% plot(1:L,Xplus1(:,1)-mean(Xplus1(:,1)),1:L,Xplus1(:,2)-mean(Xplus1(:,2)),1:L,Xplus1(:,3)-mean(Xplus1(:,3)));
% plot(2:L,X(2:40,1)-rover_pos(1),2:L,X(2:40,2)-rover_pos(2),2:L,X(2:40,3)-rover_pos(3));
% legend('X','Y','Z');
for i = 1:L
    r_r(i,:) = Xplus1(i,1:3) - rover_pos;
    rec_pos = ecef2pos(rover_pos);
    enu(i,:) = ecef2enu(rec_pos,r_r(i,:));
end
figure(2);
plot(1:L,enu);
legend('E','N','U');