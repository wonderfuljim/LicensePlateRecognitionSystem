function [ ] = recognition( )
%RECOGNITION 此处显示有关此函数的摘要
%   此处显示详细说明
global exactchara;   %字符元胞1
global bpzifu;       %字符元胞2
global doce;    %送去显示
global L1;

tic
load bpnet2.mat;
input=converion1(bpzifu{1});
Y=sim(net2,input);
Y=compet(Y);
d=find(Y==1);
switch d
    case 6
        str='京';
    case 1
        str='闽';
    case 2
        str='粤';
    case 3
        str='苏';
    case 4
        str='沪';
    case 5
        str='浙';
    case 7
        str='藏';
    case 8
        str='川';
    case 9
        str='鄂';
    case 10
        str='甘';
    case 11
        str='辽';
    case 12
        str='冀';
    case 13
        str='鲁';
    case 14
        str='吉';
    case 15
        str='琼';
    case 16
        str='青';
    case 17
        str='黑';
    case 18
        str='云';
    case 19
        str='豫';
    case 20
        str='皖';
    case 21
        str='赣';
    case 22
        str='蒙';
    case 23
        str='晋';
    case 24
        str='宁';
    case 25
        str='新';
    case 26
        str='贵';
    case 27
        str='桂';
    otherwise
end

liccode=char(['0':'9' 'A':'Z' ]);
%建立自动识别字符代码表  1~10 数字  11~36  字母 
                %l代表第几个字符
V=1;
for I=1:7
    mubanchara{I}=bwdist(exactchara{I});     %计算模板零元素与非零元素的最短距离
    exactchara{I} = double(exactchara{I});
    if V==2                                  %第二位 A~Z 字母识别
        kmin=11;
        kmax=36;
    elseif V==1
        Code(V*2-1)=str;
        Code(V*2)=' '; 
        V=V+1;
        continue;
    elseif V >= 3                         %第三位以后是字母或数字识别
        kmin=1;
        kmax=36;
    end
    for k=kmin:kmax
        fname=strcat('标准模板库\',liccode(k),'.jpg');% 每次操作字符连接地址
        SamBw = imread(fname);
        SamBw = im2bw(SamBw);   %对模板二值化
        SamBwos=bwdist(SamBw);  %计算模板零元素与非零元素的最短距离
        osdist(k)= corr2(SamBwos,mubanchara{I});  %相关度比较
    end
    test=osdist(kmin:kmax);    
    [dest,index]=max(abs(test(:)));  %找到绝对值最大的文字符号的下标
    index=index+kmin-1;              %加上前面的标号
    if index==3 || index==6 || index==9 || index==17 || index==29 || index==36 ||...
            index==26 || index==16  || index==12
        index=correcting(index,I);
    end
    Code(V*2-1)=liccode(index);
    Code(V*2)=' ';                    %空出Code数组的一个字符位
    V=V+1;
end
doce=Code;
L3=toc;
L1=L1+L3;
end


