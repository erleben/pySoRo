A = (linspace(-50,50,100))';
P = A.^2;

[mod, fmod] = k_model(P,A,1,3,1,1);

pred = fmod(A');

plot(A,P);
hold on;
plot(A,pred);

a_pred = mod(P');
a_err = mean(sum((A-a_pred).^2,2))
err = mean(sum((P-pred).^2,2))