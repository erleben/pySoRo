% Fit a curve to a sine-function

X=  0:0.01:20;
y1 = sin(X)*0.5;
y2  = X.^2;

Y = [y1', y2'];

X = normalize(X);
Y = normalize(Y);



[model,fmodel]=k_model(Y,X',1,10,0,1);

y_est = fmodel(X');
x_est = model(Y);

[lmod,lfmod]=k_model(Y,X',10,1,1,1);
yl_est = lfmod(X');

plot3(X,Y(:,1),Y(:,2));
hold on;
plot3(X,y_est(:,1),y_est(:,2));
plot3(X,yl_est(:,1),yl_est(:,2));




