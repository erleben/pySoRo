function res = exp_kmdl(order, k, n1, n2, use_solver, makePlot)

addpath('../../utilities');

if nargin < 5
    makePlot = false;
end

% This dataset contains 19 unordered points over 100 iterations
Alphas  = csvread(strcat('../../../data/experiment_2/output_exp',int2str(n1),'/alphamap.csv'));

P1=load(strcat('../data/points_exp',int2str(n1),'.csv'));
P2=load(strcat('../data/points_exp',int2str(n2),'.csv'));
Alphas  = Alphas(1:size(P1,1),3);

% Find point correspondances
F1 = [P1(10,1:3:end)',P1(10,2:3:end)',P1(10,3:3:end)'];
F2 = [P2(10,1:3:end)',P2(10,2:3:end)',P2(10,3:3:end)'];
[P1_N, P2_N] = matchPoints(F1, F2, P1, P2, 0.01);



% Train a model on the first dataset
l_mdl = k_model(P1_N, Alphas, order, k, use_solver);

res = zeros(size(P2_N,2),3);

% Evaluate on test data
for i = 1:size(P2_N,1)
    pt = P2_N(i,:)';
    res(i,1) = Alphas(i);
    l_est = l_mdl(pt);
    res(i,2) = l_est(1);
end

% Evaluate on training data
for i = 1:size(P2_N,1)
    pt = P1_N(i,:)';
    l_est = l_mdl(pt);
    res(i,3) = l_est(1);
end

res
mean(res(:,2:3)-res(:,1))
if makePlot
    figure;
    plot(res)


    xlabel('Itaration');
    ylabel('alpha-value');
    legend('Ground truth', 'Test estimate', 'Train estimate');
end
end 