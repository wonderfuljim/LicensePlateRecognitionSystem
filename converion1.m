function len = converion1( I )
%CONVERION1 此处显示有关此函数的摘要
%   此处显示详细说明
%将图片转换成列向量 

len=zeros(1,1280);
for i=1:40
    for j=1:32
        len(1,32*(i-1)+j)=I(i,j);
    end
end
len=len';
end

