function [ output_args ] = recognition2( input_args )
%RECOGNITION2 此处显示有关此函数的摘要
%   此处显示详细说明
global exactchara;   %字符元胞1
global doce;    %送去显示
global L1;

tic
liccode=char(['0':'9' 'A':'Z' '京闽粤苏沪浙藏川鄂甘辽冀鲁吉琼青黑云豫皖赣蒙晋宁新贵桂' ]);
%建立自动识别字符代码表  1~10 数字  11~36  字母  37~63 
                %l代表第几个字符
V=1;
for I=1:7
    mubanchara{I}=bwdist(exactchara{I});     %待识别字符欧氏距离
    exactchara{I} = double(exactchara{I});
    if V==2                                  %第二位 A~Z 字母识别
        kmin=11;
        kmax=36;
    elseif V==1
        kmin=37;
        kmax=63;
    elseif V >= 3                         %第三位以后是字母或数字识别
        kmin=1;
        kmax=36;
    end
    for k=kmin:kmax
        fname=strcat('标准模板库\',liccode(k),'.jpg');  %每次操作都是字符连接地址
        SamBw = imread(fname);
        SamBw = im2bw(SamBw);
        SamBwos=bwdist(SamBw);                    %字符模板欧氏距离
        osdist(k)= corr2(SamBwos,mubanchara{I});  %相关度比较
    end
    test=osdist(kmin:kmax);
    [dest,index]=max(abs(test(:)));   
    index=index+kmin-1;
    if index==3 || index==6 || index==9 || index==17 || index==29 || index==36 ||...
            index==26 || index==16  || index==12
        index=correcting(index,I);      %这一步操作是对混淆的字符进行再次验证  如Z和2、5和S这些
    end
    Code(V*2-1)=liccode(index);
    Code(V*2)=' ';                    %空出Code数组的一个字符位
    V=V+1;
end
doce=Code;
L3=toc;
L1=L1+L3;
end

