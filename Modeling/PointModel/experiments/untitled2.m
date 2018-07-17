%A = (linspace(1,50,150))';
A  = csvread(strcat('alphamap_grabber.csv'));
A = A./max(A);

P = sum(A.^2,2);
P = P./max(P);

[mod, fmod] = k_model(P,A,2,1,1,1,1);

pred = fmod(A);

plot(A,P);
hold on;
plot(A,pred);

a_pred = mod(P');
a_err = mean(sum((A-a_pred).^2,2))
err = mean(sum((P-pred).^2,2))

figure
plot(a_pred);
hold on;
plot(A);