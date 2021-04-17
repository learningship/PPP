close all;
clear all;
clc;
clf;
%°×É«±³¾°
axis([-2,2,-2,2]);
xlabel('XÖá');
ylabel('YÖá');
%ËÄÖÜµÄ±ß¿ò
box on;
%»æÍ¼ÇøÓò
t=0:0.02:10;  
Nt=size(t,2);
x=2*cos(t(1:Nt));
y=sin(t(1:Nt));
%Ñ­»·»æÍ¼
for i=1:Nt
    cla;
    hold on;
    plot(x,y)
    plot(x(i),y(i),'o');
    frame=getframe(gcf);
    imind=frame2im(frame);
    [imind,cm] = rgb2ind(imind,256);
    if i==1
         imwrite(imind,cm,'test.gif','gif', 'Loopcount',inf,'DelayTime',1e-4);
    else
         imwrite(imind,cm,'test.gif','gif','WriteMode','append','DelayTime',1e-4);
    end
end

% close all;
% clear all;
% clc;
% clf;
% xlabel('XÖá');
% ylabel('YÖá');
% box on;
% axis([-2,2,-2,2]);
% axis equal;
% pause(1);
% h=line(NaN,NaN,'marker','o','linesty','-','erasemode','none');
% t=6*pi*(0:0.02:1);
% for n=1:length(t)
%     set(h,'xdata',2*cos(t(1:n)),'ydata',sin(t(1:n)));
%     pause(0.05);
%     frame=getframe(gcf);
%     imind=frame2im(frame);
%     [imind,cm] = rgb2ind(imind,256);
%     if n==1
%          imwrite(imind,cm,'test.gif','gif', 'Loopcount',inf,'DelayTime',1e-4);
%     else
%          imwrite(imind,cm,'test.gif','gif','WriteMode','append','DelayTime',1e-4);
%     end
% end

