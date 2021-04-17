x=[0 1 1 0 0 0 1 1 0 0];
y=[0 0 1 1 0 0 0 1 1 0];
z=[0 0 0 0 0 1 1 1 1 1];
plot3(x,y,z,'k')
hold on;
for k=1:3
xp=[x(k+1),x(k+1)];
yp=[y(k+1),y(k+1)];
plot3(xp,yp,[0,1],'k');
end
x=0:1;
y=x;
[x,y]=meshgrid(x,y);
z=0.5*ones(size(x));
hold on
surf(x,y,z,'facealpha',0.9)
hold on
quiver3(0.5,0.5,0.5,-0.5,0,0,'k');
quiver3(0.5,0.5,0.5,0,-0.5,0,'k');