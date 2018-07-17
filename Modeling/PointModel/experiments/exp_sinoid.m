X=  0:0.01:10;
y1 = sin(X)*0.5;
y2  = X.^2;

Y = [y1', y2'];

X = normalize(X);
Y = normalize(Y);

plot(Y(:,1),Y(:,2));

[model,fmodel]=k_model(Y',X,4,1,1,1);
y_est = fmodel(X);
err(o) = mean(sum((y_est-Y).^2,2))


hold on;
plot(y_est(:,1),y_est(:,2));


[lmod,lfmod]=k_model(Y,X',1,1,1,1);
yl_est = lfmod(X');

plot(yl_est(:,1),yl_est(:,2));

n = 500;

sp = lfmod(X(n));
line([yl_est(n,1),Y(n,1)],[yl_est(n,2),Y(n,2)]);
