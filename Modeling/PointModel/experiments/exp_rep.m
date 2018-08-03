function [test_err, train_err] = exp_rep(n1, n2, order, K, use_solver, isPoly)

% The datasets contain 19 unordered points over 100 iterations
addpath('../../utilities/');
if nargin < 7
    makePlot = false;
end

Alphas  = csvread(strcat('../../../data/experiment_2/output_exp',int2str(n1),'/alphamap.csv'));
A = Alphas(:,2);
% Find point correspondances
P1=load(strcat('../data/points_exp',int2str(n1),'.csv'));
P2=load(strcat('../data/points_exp',int2str(n2),'.csv'));
A  = Alphas(1:size(P1,1),3);

F1 = [P1(10,1:3:end)',P1(10,2:3:end)',P1(10,3:3:end)'];
F2 = [P2(10,1:3:end)',P2(10,2:3:end)',P2(10,3:3:end)'];
[P1_N, P2_N] = matchPoints(F1, F2, P1, P2, 0.02);

% Train a model on the first dataset
model  = k_model(P1_N, A, order, K, use_solver, isPoly, 1);
res = zeros(size(P2_N,2),3);

% Evaluate on train and test datas

alpha_est_train = model(P2_N);



alpha_est_val = model(P1_N);


train_err = mean(sqrt(sum((alpha_est_train-A).^2,2)));
test_err = mean(sqrt(sum((alpha_est_val-A).^2,2)));

end
