Alphas  = csvread('../../data/output_exp1/alphamap.csv');
P1=load('datapoints_exp1.csv');
P2=load('datapoints_exp2.csv');

F1 = [P1(1,1:3:end)',P1(1,2:3:end)',P1(1,3:3:end)'];
F2 = [P2(1,1:3:end)',P2(1,2:3:end)',P2(1,3:3:end)'];

dists = pdist2(F1,F2);

[min_d, order] = min(dists);

F1 = F1(order,:);

P1_N = P1;
for i = 1:length(order)
    P1_N(:,3*i-2:3*i) = P1(:,3*order(i)-2:3*order(i));
end

csvwrite('datapoints_exp1_rearr.csv', P1_N);

addpath('../Registration/experiments');

model = trainModel(P1_N, Alphas);
res = zeros(size(P2,2),3);
for i = 1:size(P2,1)-3
    pt = [P2(i,1:3:end)'; P2(i,2:3:end)'; P2(i,3:3:end)'];
    alpha_est = model(pt);
    res(i,1) = Alphas(i, 3);
    res(i,2) = alpha_est(1);
end

for i = 1:size(P2,1)-3
    pt = [P1_N(i,1:3:end)'; P1_N(i,2:3:end)'; P1_N(i,3:3:end)'];
    alpha_est = model(pt);
    res(i,3) = alpha_est(1);
end

test_err = mean(abs(res(:,2)-res(:,1)))
train_err = mean(abs(res(:,3)-res(:,1)))

plot(res)