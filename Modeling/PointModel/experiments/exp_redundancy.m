% In this experiment, we see whether local models are able to learn the
% inverse kinematics of an non-invertible function. Non-invertible
% functions arises in soft robotics when the robot is redundant; when there
% are multiple possible configration parameters for a given shape

% x^2 is redundant, since for y(x) x!=0 -> x(y) = +- sqrt(x)

[X,Y]=meshgrid(-50:50);
x1 = reshape(X,1,numel(X));
x2 = reshape(Y,1,numel(Y));
x = [x1',x2'];
y = sum(x.^2,2);


[model, fmodel] = k_model(y,x,1,2,0,1, 1);

y_est = fmodel(x);

x_est = model(y');

y_estt = sum(x_est.^2,2);
surf(X,Y,reshape(y_estt,101,101));
hold on;
%surf(X,Y,reshape(y,101,101));


mean(y_estt-y)
