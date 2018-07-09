% Overfitting

x = (-10:0.1:10)';
y = (x-5).*(x+5).*x;
y = y+normrnd(0,100,size(y,1),size(y,2));


[mod, fmod] = k_model(y,x,6,1,1,1);

y_estt=fmod(x);
plot(x,y_estt);
hold on;
scatter(x,y,1);

[mod, fmod] = k_model(y,x,2,2,1,1);

y_est=fmod(x);
plot(x,y_est);
hold on;

legend('One 3rd-order model','Two 2nd-order models');

figure;
[mod, fmod] = k_model(y,x,1,3,1,1);

plot(x,y_estt);
hold on;
scatter(x,y,1);

y_est=fmod(x);
plot(x,y_est);
hold on;

legend('One 3rd-order model','Three 1st-order models');