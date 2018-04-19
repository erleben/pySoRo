function res = exp_local(order, n1, n2, makePlot)

addpath('../');
addpath('../../Registration/experiments');


if nargin < 4
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
model = trainModel(P1_N, Alphas, order);
m1 = trainModel(P1_N(1:33,:), Alphas(1:33), order);
m2 = trainModel(P1_N(34:66,:), Alphas(34:66), order);
m3 = trainModel(P1_N(67:end,:), Alphas(67:end), order);


res = zeros(size(P2_N,2),5);

% Evaluate on test data
for i = 1:size(P2_N,1)
    pt = [P2_N(i,1:3:end)'; P2_N(i,2:3:end)'; P2_N(i,3:3:end)'];
    alpha_est = model(pt);
    res(i,1) = Alphas(i);
    res(i,2) = alpha_est;
    
    if alpha_est(1)<100
        a_e = m1(pt);
    elseif alpha_est(1) < 200
        a_e = m2(pt);
    else 
        a_e = m3(pt);
    end
    res(i,4) = a_e(1);
end

% Evaluate on training data
for i = 1:size(P2_N,1)
    pt = [P1_N(i,1:3:end)'; P1_N(i,2:3:end)'; P1_N(i,3:3:end)'];
    alpha_est = model(pt);
    res(i,3) = alpha_est(1);
    
    if alpha_est(1)<100
        a_e = m1(pt);
    elseif alpha_est(1) < 200
        a_e = m2(pt);
    else 
        a_e = m3(pt);
    end
    res(i,5) = a_e(1);
end

train_err = mean(abs(res(:,3)-res(:,1)))
test_err = mean(abs(res(:,2)-res(:,1)))
loc_test = mean(abs(res(:,4)-res(:,1)))
loc_train = mean(abs(res(:,5)-res(:,1)))

if makePlot 
    figure;
    plot(res)


    xlabel('Itaration');
    ylabel('alpha-value');
    legend('Ground truth', 'Test estimate', 'Train estimate', 'Local test', 'Local train');
end
end 
