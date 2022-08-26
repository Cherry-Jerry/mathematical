function[weight,score] = Entropy_Weight_Method(X)
% X是n行评价对象，m列评价指标的n*m矩阵
% weight是熵权法得出的权重，是一个1*m的向量
% score 是每个指标的综合得分，是一个1*n的向量
[n,m] = size(X); % n个评价对象，m个评价指标
p = X./sum(X); % 指标比重[第i个评价对象的第j个指标与第j列指标和的比值]
p(p==0) = eps; % 排除p等于零的情况[当p=0时，p替换成趋近于0的数]
e = -sum(p.*log(p))/log(n); % 熵值计算公式
g = 1-e; % 变异系数
weight = g/sum(g); % 熵权
score = weight*p'; % 综合评价值
end