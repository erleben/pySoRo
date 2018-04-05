function [est, aest, real] = runHessOnWhitBox(num)

P = csvread('../../Calibration/datapoints_pca.csv');
Alphas  = csvread('../../../data/output/alphamap.csv');
[num_states, num_pts] = size(P);

pts = zeros(num_pts,num_states);


for i = 1:num_states
    X = reshape(P(i,1:3:end),num_pts/3,1);
    Y = reshape(P(i,2:3:end),num_pts/3,1);
    Z = reshape(P(i,3:3:end),num_pts/3,1);
    pts(:,i) = [X;Y;Z];
end

X0 = pts(:,1);
pts(:,1) = [];
U = pts-X0;

T = U(:,num);
A = Alphas(2:end,3)';
U(:,num)=[];
AA = A(num);
A(num)=[];
A_JK = [A; 0.5*(A.^2)];


% Compute Hessian
JK = (A_JK*A_JK')\(U*A_JK')';
alpha_est = round((JK*JK')\JK*T);

est_err = reshape((T- JK'*alpha_est),numel(T)/3,3);
err_jk = mean(sqrt(sum(est_err.^2,2)));
disp('Second order');
disp('alpha_test:');
disp(AA);
disp('alpha_est:');
disp(alpha_est);
disp('mse:') 
disp(err_jk);


% Use optimizer
alpha = @(a) [a(1); 0.5*a(1)^2];
%fun = @(x) mean(sqrt(sum(reshape(X0 + JK' * alpha(x) - T, length(T)/3,3).^2,2)));
%fun = @(x) mean(sqrt((X0 + JK' * alpha(x) - T).^2));
fun = @(x) mean(sqrt(sum(reshape((T- JK'*alpha(x)),numel(T)/3,3).^2,2)));

ub = max(A);
lb = min(A);

est = fmincon(fun, 150, [], [], [], [], lb, ub);
real = AA;
aest = alpha_est(1);
end