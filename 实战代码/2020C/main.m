clc,clear;

%==========================熵权法评估企业实力=================================
% 读取数据
dataTable = readtable('123家企业信贷数据汇总.xlsx'...
,'VariableNamingRule','preserve');
X = table2array(dataTable(:,2:8));

% 数据预处理
X1 = X(:,7);   % 信誉等级
X2 = X(:,1:6); % 实力
X2 = normalize(X2,'range'); % 线性变换归一化
X2(:,4) = 1 - X2(:,4); % 一致化处理："因故取消交易率"变为增益属性

% 熵权法
[weight,score] = Entropy_Weight_Method(X2);
score = normalize(score,'range');
SCORE = score + X1;
scoreTable = [dataTable(:,[1,8]) table(SCORE)];
scoreTable.Properties.VariableNames = {'企业代号' '信誉等级' '得分'};

% 按得分降序查看企业
 rank = sortrows(scoreTable,3,'descend')

%===================拟合得分和企业违约率的函数关系==============================
syms x a b c;
fun = a*exp(b*x)+c;
e1 = int(fun,x,1,2) - 24/123;
e2 = int(fun,x,2,3) - 2/123;
e3 = int(fun,x,3,4) - 1/123;
[a0,b0,c0] = solve(e1,e2,e3,a,b,c);
Score2BreachRate = @(x) a0*exp(b0*x)+c0; % 违约率-得分关系式
subplot(1,2,1)
x = (1:0.01:5);
plot(x,Score2BreachRate(x)); % 绘制拟合函数曲线
xlabel('评分s','FontSize',15,'FontWeight','bold');
ylabel('企业违约概率密度r','FontSize',15,'FontWeight','bold');

% 得分-违约率散点图
subplot(1,2,2)
x = (1:123);
SCORE_sort = table2array(rank(:,3))
scatter(SCORE_sort,Score2BreachRate(SCORE_sort));
%======================构造利率-流失率映射关系（未使用）=========================
relationship_of_rate_and_loss = ...
readmatrix('附件3：银行贷款年利率与客户流失率关系的统计数据.xlsx','Range','A3:D31');
RATE = relationship_of_rate_and_loss(:,1); % 贷款年利率
LOSS = relationship_of_rate_and_loss(:,2:4);% 信誉评级为ABC的客户流失率

% 根据企业的利率r和企业的信誉等级type(4,3,2,1)获取流率的值
findLossRate = @(r,type) LOSS(RATE==r,5-type);
% 测试
% findLossRate(0.0425,4)
% findLossRate(0.1145,2)


%====================银行贷款策略：最优化利润(未完成)========================

%============方法一（连续求解）=======

% 读取数据
relationship_of_rate_and_loss = ...
readmatrix('附件3：银行贷款年利率与客户流失率关系的统计数据.xlsx','Range','A3:D31');
x = relationship_of_rate_and_loss(:,1)';
y1 = relationship_of_rate_and_loss(:,2)';
y2 = relationship_of_rate_and_loss(:,3)';
y3 = relationship_of_rate_and_loss(:,4)';
%(F,流失率)(P，违约率 )的映射关系  
a1=polyfit(x,y1,3);
F1=@(x) a1(1)*x.^3+a1(2)*x.^2+a1(3)*x+a1(4);

a2=polyfit(x,y2,3);
F2=@(x) a2(1)*x.^3+a2(2)*x.^2+a2(3)*x+a2(4);

a3=polyfit(x,y3,3);
F3=@(x) a3(1)*x.^3+a3(2)*x.^2+a3(3)*x+a3(4);
% max优化问题

B = Score2BreachRate(table2array(rank(:,3)));
p = double(B')
p1=p(1:27); %信誉等级A的违约率
p2=p(28:65); %信誉等级B的违约率
p3=p(66:99); %信誉等级C的违约率
x0.R1=rand(27,1);x0.R2=rand(38,1);x0.R3=rand(34,1);
x0.A1=rand(27,1);x0.A2=rand(38,1);x0.A3=rand(34,1);
prob = optimproblem('ObjectiveSense','max');
% 定义决策变量：r（利润率，profit rate）
R1 = optimvar('R1',27,'LowerBound',0.04,'UpperBound',0.15);
R2 = optimvar('R2',38,'LowerBound',0.04,'UpperBound',0.15);
R3 = optimvar('R3',34,'LowerBound',0.04,'UpperBound',0.15);
% 定义决策变量：a（贷款额度，amount）
A1 = optimvar('A1',27,'LowerBound',10,'UpperBound',100);
A2 = optimvar('A2',38,'LowerBound',10,'UpperBound',100);
A3 = optimvar('A3',34,'LowerBound',10,'UpperBound',100);
Y1=sum(A1.*(1- F1(R1)).*(-p1'+(1-p1').*R1));
Y2=sum(A2.*(1-F2(R2)).*(-p2'+(1-p2').*R2));
Y3=sum(A3.*(1-F3(R3)).*(-p3'+(1-p3').*R3));

% 定义目标函数：E （银行利润期望，expectation）
% E_i=A_i*[1-F(R_i)]*[-P_i+(1-P_i)*R_i]
prob.Objective =Y1+Y2+Y3
%(F,流失率)(P，违约率 )的映射关系  

% 约束条件 

C=1000;cc=[];QQ=[];
RR1=[];RR2=[];RR3=[];
AA1=[];AA2=[];AA3=[];hold on
while C<11000
prob.Constraints.con1 = sum(A1)+sum(A2)+sum(A3)==C;
[sol,Q,flag,out] = solve(prob,x0)
cc=[cc;C];;QQ=[QQ,Q];
RR1=[RR1,sol.R1];RR2=[RR2,sol.R2];RR3=[RR3,sol.R3];
AA1=[AA1,sol.A1];AA2=[AA2,sol.A2];AA3=[AA3,sol.A3];
C=C+100;
end

% plot(cc,QQ)
scatter(cc,QQ,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5);
xlabel('总贷款额度(万)')
ylabel('收益(万)')



%============方法二（离散求解）（未完成）========
%企业数量
num = 123; 
% 根据评分计算123家企业的违约率
B = Score2BreachRate(SCORE);
% 获取企业对应的信誉等级
TYPE = X1;

% 在求最优化利润时，optimvar不接受double类型数据，
% 这里用整型变量(PRI)Profit _Rate_Index与利润率对应

prob = optimproblem('ObjectiveSense','max');
% 定义决策变量：r（利润率，profit rate）
R = optimvar('R','LowerBound',0.04,'UpperBound',0.15);
% 定义决策变量：a（贷款额度，amount）
A = optimvar('A',num,'LowerBound',10,'UpperBound',100);
% 定义目标函数：E （银行利润期望，expectation）
% 公式：Ei=Ai*(1-Li)*(Ri-Bi-Bi*Ri)
prob.Objective = sum(A*(1-findLossRate(R,TYPE))*(R-B-B*R));

% 约束条件 （未完成）
prob.Constraints.con1 = R;
prob.Constraints.con2 = A;

% 问题求解
[sol,fval,flag,out] = slove(prob)




%====================302家企业划分：信誉等级与企业实力相匹配(未完成)============

% 划分方法：双层支持向量机
% 第一层把企业分为 (AB)(CD)两种类型
% 第二层把企业分为(A)和(B)，(C)和(D)类型
% 单个支持向量机算法思路
% 把数据划分成三部分（X,Y,Z），已知X，Y是已经分为两个类别的数据
% 训练支持向量机分类器
% 计算已知样本点的错判率
% 代入Z检验分类器

clc,clear
% 读取数据
dataTable = readtable('123家企业信贷数据汇总.xlsx'...
,'VariableNamingRule','preserve');
dataTable = sortrows(dataTable,8,'descend'); % 信誉等级排序
X = table2array(dataTable(:,2:8)); % 转化成矩阵进行运算

% 数据预处理
X1 = X(:,7);   % 信誉等级
X2 = X(:,1:6); % 实力
X2 = normalize(X2,'range'); % 线性变换归一化
X2(:,4) = 1 - X2(:,4); % 一致化处理："因故取消交易率"变为增益属性

%数据标准化,列属性是分类对象，行属性是对象的属性
[X2_std,ps] = mapstd(X2');
mu = ps.xmean ;sigma = ps.xstd; % 均值向量，标准差向量
%========通过123家企业样本构造SVM分类器==========
% group1:标记样本点，AB信誉等级标记为1，CD信誉等级标记为-1
ABCDsize = 123;
group1 = zeros(ABCDsize,1);
for i = 1:ABCDsize
    if(X1(i) == 4 || X1(i) == 3)
        group1(i,1) = 1;
    end
    if(X1(i) == 2 || X1(i) == 1)
        group1(i,1) = -1;
    end
end
% group2:标记样本点，A信誉等级标记为1，B信誉等级标记为-1
ABsize = sum(group1(:,1) == 1);
group2 = zeros(ABsize,1);
for i = 1:ABsize
    if(X1(i) == 4)
        group2(i,1) = 1;
    end
    if(X1(i) == 3)
        group2(i,1) = -1;
    end
end
% group3:标记样本点，C信誉等级标记为1，D信誉等级标记为-1
CDsize = sum(group1(:,1) == -1);
group3 = zeros(CDsize,1);
for i = 1:CDsize
    if(X1(ABsize+i) == 2)
        group3(i,1) = 1;
    end
    if(X1(ABsize+i) == 1)
        group3(i,1) = -1;
    end
end

% check_mark = [X1 group1 [group2;group3]]
X_AB_CD = X2_std';
X_A_B = X2_std(:,1:ABsize)';
X_C_D = X2_std(:,ABsize+1:end)';
% 训练支持向量机分类器1,将企业分成AB和CD两类
SVM_AB_CD = fitcsvm(X_AB_CD,group1,'Standardize',true,...
    'KernelFunction','rbf','KernelScale','auto'); 
SVM_A_B = fitcsvm(X_A_B,group2,'Standardize',true,...
    'KernelFunction','rbf','KernelScale','auto'); 
SVM_C_D = fitcsvm(X_C_D,group3,'Standardize',true,...
    'KernelFunction','rbf','KernelScale','auto'); 

% 获取模型参数
%sv_index = find(s.IsSupportVector) % 支持向量的标号
%beta = s.Alpha % 分类函数的权系数
%bb = s.Bias % 分离函数的常数项


% 检验已知样本点
check_AB_CD = predict(SVM_AB_CD,X_AB_CD); 
check_A_B = predict(SVM_A_B,X_A_B);
check_C_D = predict(SVM_C_D,X_C_D);

% 计算已知样本点的错判率
fprintf("AB,CD分类器的已知样本点错判率：");
err_rate_AB_CD = 1 - sum(group1==check_AB_CD)/length(group1)
fprintf("A,B分类器的已知样本点错判率：");
err_rate_A_B = 1 - sum(group2==check_A_B)/length(group2)
fprintf("C,D分类器的已知样本点错判率：");
err_rate_C_D = 1 - sum(group3==check_C_D)/length(group3)

%========通过123家企业样本构造SVM分类器==========


% 读取数据
% （表格待完成，假设表格格式和123家企业信贷数据汇总.xlsx一样,但没有信誉等级列）
dataTable2 = readtable('302家企业的实力数据.xlsx'...
    ,'VariableNamingRule','preserve');
Z = table2array(dataTable2(:,2:7)); % 转化成矩阵进行运算

% 数据预处理
Z2 = Z(:,1:6); % 实力
Z2 = normalize(Z2,'range'); % 线性变换归一化
Z2(:,4) = 1 - Z2(:,4); % 一致化处理："因故取消交易率"变为增益属性

% 数据标准化,列属性是分类对象，行属性是对象的属性
[Z2_std,ps] = mapstd(Z2');
mu = ps.xmean ;sigma = ps.xstd; % 均值向量，标准差向量

% 检验样本点,AB/CD分类
check_AB_CD = predict(SVM_AB_CD,Z2_std'); 
dataTable2(:,8) = array2table(check_AB_CD);

%  按第一次分类排序，再次处理数据
dataTable = sortrows(dataTable2,8,'descend');
Z = table2array(dataTable2(:,2:7));
Z2 = Z(:,1:6);
Z2 = normalize(Z2,'range');
Z2(:,4) = 1 - Z2(:,4);
[Z2_std,ps] = mapstd(Z2');

% 检验样本点,A，B分类
Z_ABsize = sum(check_AB_CD(:,1) == 1);
check_A_B = predict(SVM_A_B,Z2_std(:,1:Z_ABsize)');

% 检验样本点,C，D分类
Z_CDsize = sum(check_AB_CD(:,1) == -1);
check_C_D = predict(SVM_C_D,Z2_std(:,Z_ABsize+1:end)');

check = [check_AB_CD,check_A_B;check_C_D];
Type = zeros(302,1);
for i=1:302
    if(check(i,1)==1 && check(i,2)==1)
        Type(i) = 4;
    end
    if(check(i,1)==1 && check(i,2)==-1)
        Type(i) = 3;
    end
    if(check(i,1)==-1 && check(i,2)==1)
        Type(i) = 2;
    end
    if(check(i,1)==-1 && check(i,2)==-1)
        Type(i) = 1;
    end
end
result = table(302,4); % 结果表，第一列是企业代号
                % 第二列是AB/CD判断，第三列是A/B或C/D判断，第四列是信誉等级（预测）
result(:,1) =  dataTable2(:,1);
result(:,2) =  dataTable2(:,8);
result(:,3) = array2table(check);
result(:,4) = array2table(Type);
result





