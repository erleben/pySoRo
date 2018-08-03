
fun = @(x) 1./(exp(-x)+1)+0.001*x;

A = 10:10:60;
B = -9:0.3:9;
AA = [-fliplr(A), B, A]';
A = (-60:5:60)';

PP = fun(AA);
plot(AA,fun(AA),'k')
hold on;
scatter(AA,fun(AA),10,'f','r');

P = fun(AA);
[mod, fmod] = k_model(P,AA,2,12,1,0);

a=(-60:0.1:60)';
pred = fmod(a);
plot(a,pred,'b');