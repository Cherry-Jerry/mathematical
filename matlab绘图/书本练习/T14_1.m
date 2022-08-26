clc,clear
a = [0.1 5 5000 4.47
     0.2 6 6000 5.6
     0.4 7 7000 6.7
     0.9 10 10000 2.3
     1.2 2 400 1.8];
[m,n]=size(a);
x2 = @ (qujian,lb,ub,x) (1-(qujian(1)-x)./(qujian(1)-lb)).*...
(x>=lb&x<qujian(1))+(x>=qujian(1)&x<=qujian(2))+...
(1-(x-qujian(2))./(ub-qujian(2))).*(x>qujian(2)&x<=ub);
qujian = [5,6];lb=2;ub=12;
a(:,2)=x2(qujian,lb,ub,a(:,2));
b=a./vecnorm(a)
w=[0.2 0.3 0.4 0.1];
c=b.*w;
Cstar=max(c);
Cstar(4)=min(c(:,4))
C0=min(c);
C0(4)=max(c(:,4))
Sstar=vecnorm(c-Cstar,2,2)
S0=vecnorm(c-C0,2,2)
f=S0./(Sstar+S0)
[sf,ind]=sort(f,'descend').