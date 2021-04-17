clc;
clear;
rover_pos = [-2148761.8120073779 4426673.0463592755 4044686.6014460167];
ii=1;
P1=zeros(8,851);
P2=zeros(8,851);
L1=zeros(8,851);
L2=zeros(8,851);
fp = fopen('leotestobs50.txt','r');
while 1
    tline = fgets(fp);   
    if strncmp(tline,"EOF",3)
        break;
    end
    if strncmp(tline(1:5),"D3704",7)
        P1(1,ii) = str2double(tline(8:24));
        P2(1,ii) = str2double(tline(25:39));
        L1(1,ii) = str2double(tline(71:86));
        L2(1,ii) = str2double(tline(87:102));
 elseif strncmp(tline(1:5),"D3903",7)
        P1(2,ii) = str2double(tline(8:24));
        P2(2,ii) = str2double(tline(25:39));
        L1(2,ii) = str2double(tline(71:86));
        L2(2,ii) = str2double(tline(87:102));
    elseif strncmp(tline(1:5),"D4003",7)
        P1(3,ii) = str2double(tline(8:24));
        P2(3,ii) = str2double(tline(25:39));
        L1(3,ii) = str2double(tline(71:86));
        L2(3,ii) = str2double(tline(87:102));
    elseif strncmp(tline(1:5),"D4103",7)
        P1(4,ii) = str2double(tline(8:24));
        P2(4,ii) = str2double(tline(25:39));
        L1(4,ii) = str2double(tline(71:86));
        L2(4,ii) = str2double(tline(87:102));
    elseif strncmp(tline(1:5),"D5627",7)
        P1(5,ii) = str2double(tline(8:24));
        P2(5,ii) = str2double(tline(25:39));
        L1(5,ii) = str2double(tline(71:86));
        L2(5,ii) = str2double(tline(87:102));
    elseif strncmp(tline(1:5),"D5727",7)
        P1(6,ii) = str2double(tline(8:24));
        P2(6,ii) = str2double(tline(25:39));
        L1(6,ii) = str2double(tline(71:86));
        L2(6,ii) = str2double(tline(87:102));
    elseif strncmp(tline(1:5),"D5826",7)
        P1(7,ii) = str2double(tline(8:24));
        P2(7,ii) = str2double(tline(25:39));
        L1(7,ii) = str2double(tline(71:86));
        L2(7,ii) = str2double(tline(87:102));
    elseif strncmp(tline(1:5),"D5926",7)
        P1(8,ii) = str2double(tline(8:24));
        P2(8,ii) = str2double(tline(25:39));
        L1(8,ii) = str2double(tline(71:86));
        L2(8,ii) = str2double(tline(87:102));
                    ii=ii+1;
    end
end
fclose(fp);
save leotestobs.mat P1 P2 L1 L2;

