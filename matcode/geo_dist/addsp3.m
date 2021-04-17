clc;
clear;
leo_sat = zeros(8,300,3);
i = 1;
j = 1;
k = 1;
fp = fopen('leotest.txt','r+');
while 1
    tline = fgets(fp);
    if strncmp(tline,"+ ",2)
        continue;
    elseif strncmp(tline,"++",2)
        continue;
    elseif strncmp(tline,"%c",2)
        continue;
    elseif strncmp(tline,"%f",2)
        continue;
    elseif strncmp(tline,"%i",2)
        continue;
    elseif strncmp(tline,"/*",2)
        continue;
    elseif strncmp(tline,"* ",2)
            fseek(fp,-strlength(tline),'cof');
            break;
    end
end
m = 0;
while 1
    tline = fgets(fp);   
    if strncmp(tline,"EOF",3)
        break;
    end
    if strncmp(tline,"* ",2)
        m=m+1;
        if mod(m,60)==0
            fprintf(fp,
        continue;
    end
    for k = 1:3
        leo_sat(i,j,k)=1000*str2double(tline(8+14*(k-1):8+14*k));
    end
    i = i + 1;
    if mod(i,9) == 0
        i = 1;
        j = j + 1;
    end
  
end
fclose(fp);
save leodata1.mat leo_sat;






