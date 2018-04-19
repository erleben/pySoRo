function [mse, P, Alphas] = exp_twoParam(order, c, P, Alphas, thr)

if nargin < 2
    c = 0;
end

if nargin < 5
Alphas  = csvread(strcat('alphamap.csv'));

% Find point correspondances
P=load('../ordered_twoP.csv');

Alphas  = Alphas(:,2:end);
thr = 140;
end

if c > 0
    [A, P, Alphas] = exp_twoParam(order,c-1, P, Alphas, thr-2);
    P = P(A<thr,:);
    Alphas = Alphas(A<thr,:);
end


addpath('../../Registration/experiments');

% Train a model on the first dataset
model = trainModel(P, Alphas, order);

train_err= zeros(length(Alphas),1);
% Evaluate on train

for i = 1:size(P,1) 
    pt = [P(i,1:3:end)'; P(i,2:3:end)'; P(i,3:3:end)'];
    alpha_est = model(pt);
    alpha_real = Alphas(i,:)';
    train_err(i) = sqrt(sum((alpha_est-alpha_real).^2));
end
mse=train_err ;
mean(train_err)
size(P,1)

end
