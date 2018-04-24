function res=exp_single(order, n1, n2, p_num, makePlot)

% The datasets contain 19 unordered points over 100 iterations

if nargin < 5
    makePlot = false;
end

Alphas  = csvread(strcat('../../../data/experiment_2/output_exp',int2str(n1),'/alphamap.csv'));

% Find point correspondances
P1=load(strcat('../data/points_exp',int2str(n1),'.csv'));
P2=load(strcat('../data/points_exp',int2str(n2),'.csv'));
Alphas  = Alphas(1:size(P1,1),:);

F1 = [P1(10,1:3:end)',P1(10,2:3:end)',P1(10,3:3:end)'];
F2 = [P2(10,1:3:end)',P2(10,2:3:end)',P2(10,3:3:end)'];
[P1_N, P2_N] = matchPoints(F1, F2, P1, P2, 0.02);

addpath('../../Registration/experiments');

% Train a model on the first dataset
model = trainSingle(P1_N(:,p_num:18:end), Alphas, order);
res = zeros(size(P2_N,2),3);

% Evaluate on train and test datas
for i = 1:size(P2_N,1)
    pt = P1_N(i,p_num:18:end);
    alpha_est = model(pt);
    res(i,1) = Alphas(i, 3);
    res(i,2) = alpha_est(1);
end

for i = 1:size(P2_N,1)
    pt = P2_N(i,p_num:18:end);
    alpha_est = model(pt);
    res(i,3) = alpha_est(1);
end

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
