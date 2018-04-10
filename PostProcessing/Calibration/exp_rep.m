function [test_err, train_err] = exp_rep(order, n1, n2, makePlot)

if nargin < 4
    makePlot = false;
end

Alphas  = csvread(strcat('../../data/experiment_2/output_exp',int2str(n1),'/alphamap.csv'));

P1=load(strcat('data/points_exp',int2str(n1),'.csv'));
P2=load(strcat('data/points_exp',int2str(n2),'.csv'));
Alphas  = Alphas(1:size(P1,1),:);

F1 = [P1(10,1:3:end)',P1(10,2:3:end)',P1(10,3:3:end)'];
F2 = [P2(10,1:3:end)',P2(10,2:3:end)',P2(10,3:3:end)'];

dists = pdist2(F1,F2);
dim = min(size(dists));

inds = [];

for num = 1:dim
    [i,j]=find(dists==min(dists(:)));
    inds(num, 1) = i(1);
    inds(num, 2) = j(1);
    
    dists(i(1),:) = inf;
    dists(:,j(1)) = inf;
    
end
inds = inds(1:end-1,:); 
%[min_d, inds] = min(dists);

F1 = F1(inds(:,1),:);
F2 = F2(inds(:,2),:);

P1_N = P1;
for i = 1:length(inds)
    P1_N(:,3*i-2:3*i) = P1(:,3*inds(i,1)-2:3*inds(i,1));
end

P2_N = P1;
for i = 1:length(inds)
    P2_N(:,3*i-2:3*i) = P2(:,3*inds(i,2)-2:3*inds(i,2));
end

addpath('../Registration/experiments');

model = trainModel(P1_N, Alphas, order);
res = zeros(size(P2_N,2),3);
for i = 1:size(P2_N,1)-3
    pt = [P2_N(i,1:3:end)'; P2_N(i,2:3:end)'; P2_N(i,3:3:end)'];
    alpha_est = model(pt);
    res(i,1) = Alphas(i, 3);
    res(i,2) = alpha_est(1);
end

for i = 1:size(P2_N,1)-3
    pt = [P1_N(i,1:3:end)'; P1_N(i,2:3:end)'; P1_N(i,3:3:end)'];
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
