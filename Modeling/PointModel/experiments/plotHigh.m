X = 1:100;
Y = (X-50).^2;
Y_noise = Y+rand(1,100);
[mod,fmod] = k_model(Y_noise',X',2,1,1,1);
pred = fmod(X);

figure
hold on; 
plot(X,pred');
%plot(A,pred');
scatter(X,pred');

  