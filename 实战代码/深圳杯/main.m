clc,clear;
% 读取excel中的数据，A列是市名称，B列是年份
% ??列是发展前景的二级指标
% ??列是收入的二级指标
% ??列是环境的二级指标
% 共??行，第一行是表头
A = readmatrix('人才吸引力指标.xlsx','Range','C2:AA51')
% 归一化处理
B = normalize(A,'range')
% 选取[前景、收入、环境]指标
Q = B(:,[1:5]);
S = B(:,[6:8]);
H = B(:,[9:15]);
% 熵权法计算
[weight_qianjing,score_qianjing] = Entropy_Weight_Method(Q);
[weight_shouru,score_shouru] = Entropy_Weight_Method(S);
[weight_huanjing,score_huanjing] = Entropy_Weight_Method(H);
% 层次分析法权重
C = [1,3,5;1/3,1,5/3;1/5,3/5,1]; % 比较矩阵
C1 = [1,5,7;1/5,1,3;1/7,1/3,1];  %探索
C2 = [1,2,5;1/2,1,4;1/5,1/4,1];  %立业
C3 = [1,1/2,1;2,1,2;1,1/2,1]; %维持
C4 = [1,1/5,1/4;5,1,2;4,1/2,1]; %离职
weight_AHP1 = AHP(C1)
weight_AHP2 = AHP(C2)
weight_AHP3 = AHP(C3)
weight_AHP4 = AHP(C4)
weight_AHP5 = AHP(C);
% 合成权重
WEIGHT_qianjing = weight_qianjing.*weight_AHP(1)
WEIGHT_shouru = weight_shouru.*weight_AHP(2) 
WEIGHT_huanjing = weight_huanjing.*weight_AHP(3) 
% 计算得分
SCORE_qianjing = Q* WEIGHT_qianjing'
SCORE_shouru = S* WEIGHT_shouru'
SCORE_huanjing = H* WEIGHT_huanjing'
SCORE = SCORE_qianjing + SCORE_shouru + SCORE_huanjing
% 按城市分开得分
x = [2011:2020];
y_shenzhen = [SCORE_qianjing(1:10) SCORE_shouru(1:10) SCORE_huanjing(1:10)];
y_guangzhou = [SCORE_qianjing(11:20) SCORE_shouru(11:20) SCORE_huanjing(11:20)];
y_xiamen = [SCORE_qianjing(21:30) SCORE_shouru(21:30) SCORE_huanjing(21:30)];
y_hangzhou = [SCORE_qianjing(31:40) SCORE_shouru(31:40) SCORE_huanjing(31:40)];
y_suzhou = [SCORE_qianjing(41:50) SCORE_shouru(41:50) SCORE_huanjing(41:50)];
% 量化深圳吸引力绘图
subplot(2,3,1)
bar(x,y_shenzhen,'stacked')
legend('前景评分','收入评分','环境评分','location','northwest')
subplot(2,3,2)
bar(x,y_guangzhou,'stacked')
legend('前景评分','收入评分','环境评分','location','northwest')
subplot(2,3,3)
bar(x,y_xiamen,'stacked')
legend('前景评分','收入评分','环境评分','location','northwest')
subplot(2,3,4)
bar(x,y_hangzhou,'stacked')
legend('前景评分','收入评分','环境评分','location','northwest')
subplot(2,3,5)
bar(x,y_suzhou,'stacked')
legend('前景评分','收入评分','环境评分','location','northwest')
% subplot(1,2,2)
% plot(x,y_shenzhen,'LineWidth',1.5,'MarkerSize',5)
% legend('前景评分','收入评分','环境评分','location','northwest')
