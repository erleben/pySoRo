% Fit a curve to a sine-function

X=  0:0.01:20;
y1 = sin(X)*0.5;
y2  = X.^2;

Y = [y1', y2'];

X = normalize(X);
Y = normalize(Y);

plot(Y(:,1),Y(:,2));

[model,fmodel]=k_model(Y,X',1,20,0,1);

y_est = fmodel(X');
x_est = model(Y);

y_err = mean(sqrt(sum((y_est-Y).^2,2)))
x_err = mean(sqrt(sum((x_est-X').^2,2)))

hold on;
plot(y_est(:,1),y_est(:,2));


[lmod,lfmod]=k_model(Y,X',10,1,1,1);
yl_est = lfmod(X');

plot(yl_est(:,1),yl_est(:,2));




