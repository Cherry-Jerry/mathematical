clc,clear,close all
E =[1,3,10;1,4,60;2,3,5;2,4,20;3,4,1]; % 写出图的邻接矩阵
G = graph(E(:,1),E(:,2),E(:,3)); % 将矩阵转换成图
W1 = adjacency(G,'weighted'),W2 = incidence(G) % 导出邻接矩阵和关联矩阵的稀疏矩阵
plot(G,'Layout','force','EdgeLabel',G.Edges.Weight) % 绘图，设置点分布和边的标签