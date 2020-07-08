function [ output_args ] = bprec( input_args )
%BPREC 此处显示有关此函数的摘要
%   此处显示详细说明
global bpzifu;
global doce2;    %送去显示
global L1;
tic

load eg1.mat
for i=2:7
    input=pretreatment2(bpzifu{i});
    Y=sim(net,input);
    Y=compet(Y);
    d=find(Y==1)-1;
    if(d==10)
        str='A';
    elseif(d==11)
        str='B';
    elseif(d==12)
        str='C';
    elseif(d==13)
        str='D';
    elseif(d==14)
        str='E';
    elseif(d==15)
        str='F';
    elseif(d==16)
        str='G';
    elseif(d==17)
        str='H';
    elseif(d==18)
        str='J';
    elseif(d==19)
        str='K';
    elseif(d==20)
        str='L';
    elseif(d==21)
        str='M';
    elseif(d==22)
        str='N';
    elseif(d==23)
        str='P';
    elseif(d==24)
        str='Q';
    elseif(d==25)
        str='R';
    elseif(d==26)
        str='S';
    elseif(d==27)
        str='T';
    elseif(d==28)
        str='U';
    elseif(d==29)
        str='V';
    elseif(d==30)
        str='W';
    elseif(d==31)
        str='X';
    elseif(d==32)
        str='Y';
    elseif(d==33)
        str='Z'; 
    else
        str=num2str(d);
    end
    switch i
        case 2
            str1=str;
        case 3
            str2=str;
        case 4
            str3=str;
        case 5
            str4=str;
        case 6
            str5=str;
        otherwise
            str6=str;
    end
end
doce2=strcat('',str1,str2,str3,str4,str5,str6);
L3=toc;
L1=L1+L3;

end

