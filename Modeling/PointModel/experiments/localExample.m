P = ((1:0.1:10)-5);
%P=sin(P/3)./(P+1);
%P = P+ rand(size(P))*0.1;
%add outlier
P(50:55) = P(50:55).*2
A = 1:0.1:10;

plot(A,P);

[mod, fmod] = k_model(P',A',1,1,1,1);

hold on;

pred = fmod(A');
plot(A,pred,'*','MarkerSize',1)

mean(sqrt((pred'-P).^2))

a_pred = mod(P);
figure;
scatter(P,a_pred);