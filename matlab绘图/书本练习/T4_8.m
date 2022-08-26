% =====Floyd算法============
clc,clear,a = zeros(4);
a(1,[3,4]) = [10,60]; a(2,[3,4]) = [5,20]; a(3,4) = 1; % 输入上三角邻接矩阵
n =length(a);
b = a+a'; % 补全为完邻接矩阵
b(b==0) =inf; % 把零元素替换成inf
b(1:n+1:end)=0; % 把对角线元素替换成0
for k=1:n
  for i=1:n
    for j=1:n
      if b(i,k)+b(k,j) < b(i,j)
        b(i,j) = b(i,k) + b(k,j);
      end
    end
  end
end
b % 输出最短距离矩阵