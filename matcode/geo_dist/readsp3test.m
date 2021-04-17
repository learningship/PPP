clc;
clear;
leo_sat = zeros(8,300,3);
i = 1;
j = 1;
k = 1;
fp = fopen('leo_data.txt','r');
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
while 1
    tline = fgets(fp);   
    if strncmp(tline,"EOF",3)
        break;
    end
    if strncmp(tline,"* ",2)
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
save leodata.mat leo_sat;






