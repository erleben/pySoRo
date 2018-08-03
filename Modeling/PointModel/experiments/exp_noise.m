function [test_err, train_err] = exp_noise(order, n1, n2, sigma, use_solver, makePlot)

addpath('../../utilities/');
% The datasets contain 19 unordered points over 100 iterations

if nargin < 6
    makePlot = false;
end

Alphas  = csvread(strcat('../../../data/experiment_2/output_exp',int2str(n1),'/alphamap.csv'));
Alphas = Alphas(:,3:end);
% Find point correspondances
P1=load(strcat('../data/points_exp',int2str(n1),'.csv'));
P2=load(strcat('../data/points_exp',int2str(n2),'.csv'));
Alphas  = Alphas(1:size(P1,1),:);

F1 = [P1(10,1:3:end)',P1(10,2:3:end)',P1(10,3:3:end)'];
F2 = [P2(10,1:3:end)',P2(10,2:3:end)',P2(10,3:3:end)'];
[P1_N, P2_N] = matchPoints(F1, F2, P1, P2, 0.02);

P1_N = P1_N + normrnd(0, sigma, size(P1_N));
P2_N = P2_N + normrnd(0, sigma, size(P2_N));

% Train a model on the first dataset
model = trainModel(P1_N, Alphas, order, use_solver);
res = zeros(size(P2_N,1),3);

% Evaluate on train and test data

res(:,1) = Alphas';
res(:,2) = model(P1_N)';
res(:,3) = model(P2_N)';


train_err = mean(abs(res(:,3)-res(:,1)));
test_err = mean(abs(res(:,2)-res(:,1)));

if makePlot
    figure;
    plot(res)

    xlabel('Itaration');
    ylabel('alpha-value');
    legend('Ground truth', 'Test estimate', 'Train estimate');
end
end
