clc;
clear;
rover_pos = [-2148761.8120073779 4426673.0463592755 4044686.6014460167];
ii=1;
fp = fopen('leo_data278.txt','r');
while 1
    tline = fgets(fp);   
    if strncmp(tline,"EOF",3)
        break;
    end
    if strncmp(tline(28:34),"sat1143",7)
        sat1143(ii,1) = str2double(tline(35:50));
        sat1143(ii,2) = str2double(tline(51:64));
        sat1143(ii,3) = str2double(tline(65:78));
        sat1143(ii,4) = str2double(tline(79:89));
    elseif strncmp(tline(28:34),"sat1202",7)
        sat1202(ii,1) = str2double(tline(35:50));
        sat1202(ii,2) = str2double(tline(51:64));
        sat1202(ii,3) = str2double(tline(65:78));
        sat1202(ii,4) = str2double(tline(79:89));
     elseif strncmp(tline(28:34),"sat1232",7)
        sat1232(ii,1) = str2double(tline(35:50));
        sat1232(ii,2) = str2double(tline(51:64));
        sat1232(ii,3) = str2double(tline(65:78));
        sat1232(ii,4) = str2double(tline(79:89));
     elseif strncmp(tline(28:34),"sat1262",7)
        sat1262(ii,1) = str2double(tline(35:50));
        sat1262(ii,2) = str2double(tline(51:64));
        sat1262(ii,3) = str2double(tline(65:78));
        sat1262(ii,4) = str2double(tline(79:89));
     elseif strncmp(tline(28:34),"sat1736",7)
        sat1736(ii,1) = str2double(tline(35:50));
        sat1736(ii,2) = str2double(tline(51:64));
        sat1736(ii,3) = str2double(tline(65:78));
        sat1736(ii,4) = str2double(tline(79:89));
     elseif strncmp(tline(28:34),"sat1766",7)
        sat1766(ii,1) = str2double(tline(35:50));
        sat1766(ii,2) = str2double(tline(51:64));
        sat1766(ii,3) = str2double(tline(65:78));
        sat1766(ii,4) = str2double(tline(79:89));
     elseif strncmp(tline(28:34),"sat1795",7)
        sat1795(ii,1) = str2double(tline(35:50));
        sat1795(ii,2) = str2double(tline(51:64));
        sat1795(ii,3) = str2double(tline(65:78));
        sat1795(ii,4) = str2double(tline(79:89));
     elseif strncmp(tline(28:34),"sat1825",7)
        sat1825(ii,1) = str2double(tline(35:50));
        sat1825(ii,2) = str2double(tline(51:64));
        sat1825(ii,3) = str2double(tline(65:78));
        sat1825(ii,4) = str2double(tline(79:89));
                    ii=ii+1;
    end
end
fclose(fp);
sat = [sat1143';sat1202';sat1232';sat1262';sat1736';sat1766';sat1795';sat1825'];
save leostapos.mat sat;