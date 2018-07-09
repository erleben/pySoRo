x = (-100:0.1:100)';
y = (x-50).*(x+50).*x;

x = normalize(x);
y = normalize(y);

[mod, fmod] = k_model(y,x,3,1,1,1);

y_estt=fmod(x);
plot(x,y_estt);
hold on;

[mod, fmod] = k_model(y,x,2,2,1,1);

y_est=fmod(x);
plot(x,y_est);
hold on;

legend('One 3rd-order model','Two 2nd-order models');

figure;
[mod, fmod] = k_model(y,x,1,3,1,1);

plot(x,y_estt);
hold on;

y_est=fmod(x);
plot(x,y_est);
hold on;

legend('One 3rd-order model','Three 1st-order models');