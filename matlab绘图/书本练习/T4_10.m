clc,clear,close all
a = zeros(6); 
a(1,[2 5]) = [20 15];
a(2,[3:5]) = [20 60 25];
a(3,[4 5]) = [30 18];
a(5,6) = 15;
s = cellstr(strcat('v',int2str([1:6]')));
G = graph(a,s,'upper');
d = distances(G)
plot(G,'EdgeLabel',G.Edges.Weight,'Layout','force')
d1 = max(d,[],2) % 最大距离
[d2,ind] = min(d1) % 最小值，最小值地址
v = find(d(ind,:)==d2) % d2 地址