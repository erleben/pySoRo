N = 300;
K = 1;

P=normrnd(0,0.0005,N,K);

A = (1:N)';

[mod,fmod] = k_model(P,A,1,3,1,1);
plot(A,P);
hold on;
pred = fmod(A);
plot(A,pred);

mean(abs(P-pred))

e = @(s,N,K,B,a)  s*sqrt(length(A))*(1/min(svd(A-A(1))))*A+ sqrt(2/pi)*s;

mean(abs(e(0.01,1,300,A,300)))