function [ output_args ] = Dingwei( input_args )
%DINGWEI 此处显示有关此函数的摘要  定位函数
%   此处显示详细说明
global I;            %照片原图
global exactarea;    %车牌精确定位彩色RGB图:到GUI界面显示
global Yexactbw;     %送去字符切割(行合理二值图)
global L1;           %时间
tic
Igray=rgb2gray(I);                                            %灰度化
%*************灰度图处理************************************
%图像平滑
Igray=double(Igray);
ma=double(max(max(Igray)));
mi=double(min(min(Igray)));
Igray=(255/(ma-mi))*Igray-(255*mi)/(ma-mi);
Igray=uint8(Igray);
%****************突出目标对象***********
SE=strel('disk',15);            %半径为r=20的圆的模板
IS=imopen(Igray,SE);            %开运算    
%用原始图像与背景图像作减法，增强图像
Igray=imsubtract(Igray,IS);     %无干扰灰度图
%*******************************************************

%************二值化************************************
%找二值化上限TH，二值化下限TL
%***********二值化下限TL*****
TH=100;TL=30;      %设定下限是30，上限是100  第一次65  最高阈值小于65不能识别
XC=1;              %循环次数预置
uefc=2;            %能否找到车牌的标志
while XC<=4
    if uefc==0     %能找到车牌
        TH = V;    %降低
    elseif uefc==1
        TL = V;    %升高
    end
    V = round((TH+TL)/2);                  %  取中值
    test = imbinarize(Igray,V/255);        %用二分值V进行二值化得到测试用的二值图
    testedge = bwperim(test);              %边缘处理
    %*******（看一下是否可以找到车牌） 
    testedge=double(testedge);
    [y,x,~] = size(testedge);
    temp11 = 10;                            %水平阈值
    temp12 = 80;
    cary = y;                              %车牌最下面一行
    num = 0;                               %垂直方向跳变次数初始值
    Im1=sum(testedge,2);                       %用于记录行扫描时白点的个数 
    
    uefc=0;
    while  num <= 5  || num>=15
        %*******水平投影部分的列向量检索，从底行开始
        while  ( Im1(cary,1)<temp11 || Im1(cary,1)>temp12 )
            cary=cary-1;
            if cary < round(y/3)
                break;
            end
        end
        if cary < round(y/3)
            uefc=1;
            break;
        end
        flag1=cary;                 %标记下界          
        while   Im1(cary,1)>=temp11 && Im1(cary,1)<=temp12
            cary=cary-1; 
            if cary < round(y/3)
                break;
            end
        end
        flag2=cary;                %标记上界  
        if (flag1-flag2)<=10        %小于10则跳过下面
            continue;
        end
        %******* 此时得到有待验证的  横条区域
        %验证一下：作垂直投影
            book=testedge(flag2:flag1,1:x);     % 截取出来给 测试图 book                   
            Im2=sum(book,1);                    %扫描结束得到待验证图的垂直行向量Im2  
            [booky,~]=size(book);              
            temp2=3;         %确定是否有分割空隙的阈值  
            flag3=0;         %设定标志位
            num=0;           %跳变次数归零
            for i=1:x
                if flag3==0 && Im2(1,i)>temp2
                    flag3=1;
                    begin=i;
                end
                if flag3==1 && Im2(1,i)<=temp2
                    if (i-begin<3) || ( (i-begin)> booky*4/5 )
                        flag3=0;
                    else
                        flag3=0;
                        num=num+1;
                    end
                end
            end
            %检查结束
            if  num <= 5 || num>=15
                if booky>80
                    cary=flag1-10;
                else
                    cary=flag2-1;
                end
            end
    end
    XC=XC+1;
end
TLL=V;              %设置为下限
%*******************************************************
%***********寻找二值化上限TH***************************
TH=170;TL=TLL;      %设定下限是TLL，上限是TH
XC=1;              %循环次数
uefc=2;            %能否找到车牌的标志
while XC<=4
    if uefc==0     %能找到车牌
        TL = V;    %升高
    elseif uefc==1
        TH = V;    %降低
    end
    V = round((TH+TL)/2);                  %  取中值
    test = imbinarize(Igray,V/255);        %用二分值V进行二值化得到测试用的二值图
    testedge = bwperim(test);
    %*******（看一下是否可以找到车牌）
    testedge=double(testedge);
    [y,x,~] = size(testedge);
    temp11 = 10;                            %水平阈值
    temp12 = 80;
    cary = y;                              %车牌最下面一行
    num = 0;                               %垂直方向跳变次数初始值
    Im1=sum(testedge,2);                   %用于记录行扫描时白点的个数   
    uefc=0;
    
    while  num <= 5 || num>=15
        %*******水平投影部分的列向量检索，从底行开始
        while  ( Im1(cary,1)<temp11 || Im1(cary,1)>temp12 )
            cary=cary-1;
            if cary < round(y/3)
                break;
            end
        end
        if cary < round(y/3)
            uefc=1;
            break;
        end
        flag1=cary;                 %标记下行          
        while   Im1(cary,1)>=temp11 && Im1(cary,1)<=temp12
            cary=cary-1; 
            if cary < round(y/3)
                break;
            end
        end
        flag2=cary;                %标记上行      
        if (flag1-flag2)<10        %小于10则跳过下面
            continue;
        end
        %******* 此时得到有待验证的  横条区域
        %验证一下：作垂直投影
            book=testedge(flag2:flag1,1:x);     % 截取出来给 测试图 book                   
            Im2=sum(book,1);                    %扫描结束得到待验证图的垂直行向量Im2  
            [booky,~]=size(book);              
            temp2=3;         %确定是否有分割空隙的阈值  
            flag3=0;         %设定标志位
            num=0;           %跳变次数归零
            for i=1:x
                if flag3==0 && Im2(1,i)>temp2
                    flag3=1;
                    begin=i;
                end
                if flag3==1 && Im2(1,i)<=temp2
                    if (i-begin<3) || ( (i-begin)> booky*4/5 )
                        flag3=0;
                    else
                        flag3=0;
                        num=num+1;
                    end
                end
            end
            %检查结束
            if  num <= 5 || num>=15
                if booky>80
                    cary=flag1-10;
                else
                    cary=flag2-1;
                end
            end
    end
    XC=XC+1;
end
TH=V;                  %设置为上限
zz=((TH+TLL)/2)*1.1;
%*******************************************************
Thresh=zz/255;                %确定这个图片的最后阈值              
Ibinary=imbinarize(Igray,Thresh);       %执行最后的二值化

Iedge = bwperim(Ibinary);             %边缘化
I1=imclearborder(Iedge,8);            % 8 连通I1
%*********************************************
%***************第一次粗定位*****************
st1=ones(2,14);
st3=ones(2,7); 
I2=imclose(I1,st1);                  %闭
Iarea=imopen(I2,st3);                %开
Iarea=bwareaopen(Iarea,600);         %小对象删除

[Iareay,Iareax]=size(Iarea);
[U,areanum] = bwlabel(Iarea,8);      %区域标记
Feastats=regionprops(U,'all');       %区域特征提取
Area=[Feastats.Area];                %区域像素数组
rects = cat(1,Feastats.BoundingBox);   
rects=int16(rects);
rougharea=[];                        %粗定位彩色图
while  any(Area)~= 0
    [~,index]=max(Area);
    cornerx=rects(index,1);   %左上角坐标
    cornery=rects(index,2);
    width=rects(index,3);     %宽
    width=double(width);
    height=rects(index,4);    %高
    height=double(height);
    proportion=width/height;
    %**********一、比例和宽度特征验证*******
    if proportion<3.5  || proportion>6.5
        Area(index)=0;
        continue;
    end
    if ( width/Iareax >0.45 || width/Iareax <0.15 )
        Area(index)=0;
        continue;
    end
    %******************************
    testbw=imcrop(Ibinary,[cornerx cornery width height]);   %将二值图区域剪切出来测试
    testbw=double(testbw);
    [testbwy,testbwx]=size(testbw);
    Im3=sum(testbw,1);
    %*********二、binary图白点概率特征验证******
    T=( sum(Im3)/(width*height) );
    if  T>0.7  ||  T<0.2
        Area(index)=0;
        continue;
    end
    %*******三、峰谷跳变次数特征验证*******
    TH=(testbwy/4.5);
    flag3=0;                          %设定标志位
    num=0;                            %跳变次数归零
    for i=1:testbwx
        if flag3==0 && Im3(1,i)>=TH
            flag3=1;
            begin=i;
        end
        if flag3==1 && Im3(1,i)<TH
            if (i-begin)>(testbwy*2/3) || (i-begin)<3
                flag3=0;
            else
                flag3=0;
                num=num+1;
            end
        end
    end
    if num >=7 && num <=13
        rougharea=imcrop(I,[cornerx cornery width height]);     %将粗彩图剪切出来
        roughbw=imcrop(Ibinary,[cornerx cornery width height]); %将粗二值图剪切出来
        roughedge=imcrop(Iedge,[cornerx cornery width height]); %将粗二值图剪切出来
        break;
    else
        Area(index)=0;
    end
end
effect=isempty(rougharea);
if effect == 0   %如果找到

    findout=1;
else             %没找到
    findout=0;
end

%********************第二次粗定位************************
if findout==0
    st1=ones(2,28);           %与第一次粗定位不同的结构元素
    st2=ones(2,10);
    I2=imclose(I1,st1);                  %闭
    Iarea=imopen(I2,st2);
%     Iarea=imopen(Iarea,ones(10,1));
    Iarea=bwareaopen(Iarea,1300);        %小对象删除

    %**********************车牌区域粗定位**********************
    [U,areanum] = bwlabel(Iarea,8);      %区域标记
    Feastats=regionprops(U,'all');       %区域特征提取
    Area=[Feastats.Area];                %区域像素数组
    rects = cat(1,Feastats.BoundingBox);
    rects=int16(rects);
    rougharea=[];                        %粗定位彩色图
    while  any(Area)~= 0
        [~,index]=max(Area);
        cornerx=rects(index,1);   %左上角坐标
        cornery=rects(index,2);
        width=rects(index,3);     %宽
        width=double(width);
        height=rects(index,4);    %高
        height=double(height);
        proportion=width/height;
        %**********一、比例特征验证*******
        if proportion<2.5  || proportion>5.5
            Area(index)=0;
            continue;
        end
        if ( width/Iareax >0.6 || width/Iareax <0.15 )
            Area(index)=0;
            continue;
        end
        %******************************
        testbw=imcrop(Ibinary,[cornerx cornery width height]);   %将二值图区域剪切出来测试
        testbw=double(testbw);
        [testbwy,testbwx]=size(testbw);
        Im3=sum(testbw,1);
        %*********二、binary图白点概率特征验证******
        T=( sum(Im3)/(width*height) );
        if  T>0.5  ||  T<0.1
            Area(index)=0;
            continue;
        end
        %*******三、峰谷跳变次数特征验证*******
        TH=(testbwy/4.5);
        flag3=0;                          %设定标志位
        num=0;                            %跳变次数归零
        for i=1:testbwx
            if flag3==0 && Im3(1,i)>=TH
                flag3=1;
                begin=i;
            end
            if flag3==1 && Im3(1,i)<TH
                if (i-begin)>(testbwy*2/3) || (i-begin)<3
                    flag3=0;
                else
                    flag3=0;
                    num=num+1;
                end
            end
        end
        if num >=6 && num <=12
            rougharea=imcrop(I,[cornerx cornery width height]);     %将粗彩图剪切出来
            roughbw=imcrop(Ibinary,[cornerx cornery width height]); %将粗二值图剪切出来
            roughedge=imcrop(Iedge,[cornerx cornery width height]); %将边缘图剪切出来
            break;
        else
            Area(index)=0;
        end
    end
    effect=isempty(rougharea);
end

%************倾斜校正************
if effect == 0    
    theta = 0:1:179;
    [r, xp] = radon(roughedge,theta);
    len = sum(r > 0);
    [l, index] = min(len);
    theta = theta(index);
    rougharea = imrotate(rougharea,90-theta, 'crop');
    roughbw = imrotate(roughbw,90-theta, 'crop');
end
%*******车牌去除边框和铆钉：精确定位**************
if effect == 0
    find=1;
    [roughbwy,roughbwx,~]=size(roughbw);  %求大小
    flag4=0;                              %设定标志位
    exactnum=zeros(roughbwy,1);      
    for i=roughbwy:-1:1
        for j=1:roughbwx
            if flag4==0  && roughbw(i,j)==1
                flag4=1;
            end
            if flag4==1 && roughbw(i,j)==0
                flag4=0;
                exactnum(i,1)=exactnum(i,1)+1;
            end
        end
    end
    TH1=6;                     %跳变次数阈值6-18次
    TH2=18;
    nowcary=1;
    while 1             %行合理范围寻找 
    %****************首行向下扫描
        while  exactnum(nowcary,1)<TH1  ||  exactnum(nowcary,1)>TH2
            nowcary=nowcary+1;
            if nowcary == roughbwy
                break;
            end
        end
        if nowcary == roughbwy
            find=0;
            break;
        end
        flag1=nowcary;                       
        %标记上界
        while   exactnum(nowcary,1)>=TH1  && exactnum(nowcary,1)<=TH2
            nowcary=nowcary+1;
            if nowcary == roughbwy 
                break;
            end
        end
        flag2=nowcary;                      
        %标记下界
        if flag2-flag1 < round(roughbwy/3)
            continue;
        else         
            Yexactbw=roughbw(flag1:flag2,1:roughbwx);
            exactarea=rougharea(flag1:flag2,1:roughbwx,:);        
            break;
        end
    end
end
L1=toc;
%**************以下为执行弹出额外的观察框的操作*************
global shibie;
if shibie==0
    figure(2);
    subplot(2,3,1);
    imshow(Ibinary);title('二值图');
    subplot(2,3,2);
    imshow(Iarea);title('块状图');
    if effect == 0         %粗定位找到了
        figure(2);
        subplot(2,3,3);
        imshow(rougharea);title('粗定位彩图');
        if find==0     %找到的不是车牌
            figure(2);
            subplot(2,3,3);
            cla;
            title('失败');
            subplot(2,3,4);
            cla;
            subplot(2,3,5);
            cla;
            rougharea=[];
        else
            subplot(2,3,4);
            imshow(Yexactbw);title('去上下边框');
            subplot(2,3,5);
            imshow(rougharea);
            title('校正后 ');
        end
    else                 %没找到
        figure(2);
        subplot(2,3,3);
        cla;
        title('失败');
        subplot(2,3,4);
        cla;
        subplot(2,3,5);
        cla;
    end
end
end

