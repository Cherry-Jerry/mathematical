clc,clear,close all
E = [1,2;1,3;2,3;3,2;3,5;4,2;4,6;5,2;5,4;6,5];
s = E(:,1); t = E(:,2);
nodes = cellstr(strcat('v',int2str([1:6]')))
G = digraph(s,t,[],nodes);
plot(G,'LineWidth',1.5,'Layout','circl.e','NodeFontSize',15)