function y0 = interppol(tint,y, n)

for j=1:n
    tt(j)=tint*(j-1)-0.01;
end
for j=2:n
    for i=1:n-j-1
        y(i)=(tt(i+j)*y(i)-tt(i)*y(i+1))/(tt(i+j)-tt(i));
    end
end
y0 = y(1);