%%kalman filter
%X(K)=F*X(K-1)+Q
%Y(K)=H*X(K)+R

%生成�?段时�?
t=0.1:0.01:1;
L=length(t);
%生成真实信号
%首先初始�?
x=zeros(1,L);
y=x;
%生成信号，设x=t^2
for i=1:L
    x(i)=t(i)^2;
    y(i)=x(i)+normrnd(0,0.1);%正�?�分布，参数为期望方�?
end
%plot(t,x,t,y);
%%信号生成完毕

%%滤波算法%%
%预测方程？？%%
%观测方程Y(K)=X(K)+R R~N(0,1)
%模型�?
%X(K)=X(K-1)+Q
%Y(K)=X(K)+R
%Q~N(0,1)
F1=1;
H1=1;
Q1=1;
R1=0.11;
%初始化x(k)+
Xplus1=zeros(1,L);

%设置初�?�，假设Xplus1(1)~N(0.01,0.01^2)
Xplus1(1)=1;
Pplus1=0.01^2;
%%%卡尔曼滤波算�?
%X(K)minus=F*X(K-1)plus
%P(K)minus=F*P(K-1)plus*F'+Q
%K=P(K)minus*H'*inv(H*P(K)minus*H'+R)
%X(K)plus=X(K)minus+K*(y(k)-H*X(K)minus)
%P(K)plus=(1-K*H)*P(K)minus
for i=2:L
    %%%预测�?%%
    Xminus1=F1*Xplus1(i-1);
    Pminus1=F1*Pplus1*F1'+Q1;
    %%%更新�?%%
    K=(Pminus1*H1')*inv(H1*Pminus1*H1'+R1);
    Xplus1(i)=Xminus1+K*(y(i)-H1*Xminus1);
    Pplus1=(1-K*H1)*Pminus1;
end

%plot(t,x,'r',t,y,'g',t,Xplus1,'b','LineWidth',1);

%%模型�?
%X(K)=X(K-1)+X'(K-1)*dt+X(K-1)*dt^2(1/2!)+Q2
%Y(K)=X(K)+R R~N(0,1)
%此时状�?�变量X+[X(K) X'(K) X"(K)]T(列向�?)
%Y(K)=H*X+R H=[1 0 0](行向量）
%预测方程
%X(K)=X(K-1)+X'(K-1)*dt+X(K-1)*dt^2(1/2!)+Q2
%X'(K)=0*X(K-1)+X'(K-1)+X(K-1)*dt+Q3
%X"(K)=0*X(K-1)+0*X'(K-1)+X(K-1)+Q4
%F=1 dt 0.5*dt^2
%  0  1     dt
%  0  0     1
%H=[1  0  0]
%Q=Q2  0  0
%  0  Q3  0
%  0   0  Q4
dt=t(2)-t(1);
F2=[1,dt,0.5*dt^2;0,1,dt;0,0,1];
H2=[1,0,0];
Q2=[1,0,0;0,0.01,0;0,0,0001];
R2=20;
%%%设置初�??%%%
Xplus2=zeros(3,L);
Xplus2(1,1)=0.1^2;
Xplus2(2,1)=0;
Xplus2(3,1)=0;
Pplus2=[0.01,0,0;0,0.01,0;0,0,0.0001];
for i=2:L
    %%%预测�?%%%
    Xminus2=F2*Xplus2(:,i-1);
    Pminus2=F2*Pplus2*F2'+Q2;
    %%%更新�?%%%
    K2=(Pminus2*H2')*inv(H2*Pminus2*H2'+R2);
    Xplus2(:,i)=Xminus2+K2*(y(i)-H2*Xminus2);
    Pplus2=(eye(3)-K2*H2)*Pminus2;
end
plot(t,x,'r',t,y,'g',t,Xplus2(1,:),'b','LineWidth',1);    





















