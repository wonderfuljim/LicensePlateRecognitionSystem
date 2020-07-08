function [] = piccrop()
%PICCROP 剪切字符函数
%   此处显示详细说明
global Yexactbw;    %行合理范围二值图
global exactchara;  %送去  识别
global L1;          %时间记录
global bpzifu;

tic
[y,x]=size(Yexactbw);
% Yexactbw=double(Yexactbw);
Is1=sum(Yexactbw,1);          % 垂直投影(行向量)
Flag=0;
num=1;                         %第几个slice字符矩形块
%****************记录每一个矩形块的所有信息**********************
for i=1:x
    if Is1(i)>=2 &&  Flag==0
        Flag=1;
        begin=i;
    end
    if (Is1(i)<2 &&  Flag==1) || (i==x && Flag==1)
        Flag=0;
        slice.tag(1,num)='N';                                      %标号                       
        slice.length(1,num)=i-begin;                               %字符长度
        slice.asprat(1,num)=y/slice.length(1,num);                 %字符高宽比例
        slice.chara{num}=imcrop(Yexactbw,[begin 1 (i-begin) y]);   %剪切图
        slice.ratio(1,num)= sum(sum(slice.chara{num})) / ( y*slice.length(num)) ;%白色点占比
        num=num+1;      
    end
end

j=1;
for i=1:num-1
    if slice.asprat(1,i)<=2.8 && slice.asprat(1,i)>=1.5   %宽高比符合正常大字的搞进来 条件一
       slice.tag(1,i)='Y';   
    end
    if slice.ratio(1,i)  < 0.2 || slice.ratio(1,i)>0.7   %符合条件一 但 是所有白点比例不满足要求的搞出去
       slice.tag(1,i)='N'; 
    end   
    if slice.asprat(1,i)>4 && slice.asprat(1,i)<=13 && slice.ratio(1,i)>0.4  %  有竖条 '▎' 特征  可能是1或者偏旁或者边框
       idx(j)=i; %记录一下是第几个
       j=j+1;
       slice.tag(1,i)='Y';  %先搞进来
    end
    if slice.asprat(1,i)<6 && slice.asprat(1,i)>2.8 && i<6 && i>1    % 可能是汉字右边部首 
        combine=y/(slice.length(1,i)+slice.length(1,i-1)); %组合一下看是否可以
        if combine<=2.6 && combine>=1.5  %如果符合汉字右边部首 
            slice.chara{i}=[slice.chara{i-1}, slice.chara{i}];
            slice.tag(1,i-1)='N';
            slice.tag(1,i)='Y';
            slice.asprat(1,i)=2.5;
        end
    end
end

%**************************分类讨论  '▎' 特征************

if j>1    %至少有一个 '▎' 特征
    if j>=4 && idx(3)-idx(1)==2 && slice.asprat(1,idx(3)+1)<2.5   % 大概率是“川”
        slice.chara{idx(3)}=[slice.chara{idx(1)}, slice.chara{idx(2)}, slice.chara{idx(3)}];
        slice.tag(1,idx(1))='N';slice.tag(1,idx(2))='N';
    elseif j>=5 && idx(4)-idx(2)==2  % 大概率是边框和川组合：“ [川 ”
        slice.chara{idx(4)}=[slice.chara{idx(2)}, slice.chara{idx(3)}, slice.chara{idx(4)}];
        slice.tag(1,idx(1))='N';slice.tag(1,idx(2))='N';slice.tag(1,idx(3))='N';
    elseif idx(1)<3  && slice.asprat(1,idx(1))~=2.5   %  '▎' 有一个或者两个 但是第一个 '▎' 排位低于三号
        slice.tag(1,idx(1))='N';             %   边框去掉
    end
end

k=find(slice.tag=='Y');   %找到所有字符标号为“Y”的字符块
% figure(3);
Yzero=zeros(y,2);
Xzero=zeros(2,32);
global shibie;
%将字符切割出来给到存储的数组
if length(k)>=7
    for j=1:7     
        exactchara{j}=imresize(slice.chara{k(j)},[40 20]);   %归一化
        bpzifu{j}= [Yzero,slice.chara{k(j)},Yzero];
        bpzifu{j}=imresize(bpzifu{j},[36 32]);               %归一化
        bpzifu{j}= [Xzero;bpzifu{j};Xzero];
        if shibie==1
            figure(3);
            subplot(2,7,j);
            imshow(exactchara{j});
            subplot(2,7,j+7);
            imshow(bpzifu{j})
        end
        bpzifu{j}=uint8(bpzifu{j});
        exactchara{j}=uint8(exactchara{j});
    end
else
    if shibie==1
        figure(3);
        title('失败');
    end
end
L2=toc;
L1=L1+L2;
end

