function [msTrainE, msValE, model] = exp_twoParam(order, k, gmodel)

Alphas  = csvread(strcat('alphamap.csv'));
P=load('../ordered_twoP.csv');
Alphas  = Alphas(:,2:end);
do_val = true;

if do_val
    Train_inds = datasample(1:size(Alphas,1),2300,'Replace', false);
else
    Train_inds = 1:size(Alphas,1);
end
Val_inds = setdiff(1:size(Alphas,1), Train_inds);

Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);

Val = P(Val_inds,:);
A_val = Alphas(Val_inds,:);

addpath('../../Registration/experiments');

% Train a model on the first dataset
%model = trainModel(P, Alphas, order);
if nargin < 3
    model = k_model(Train, A_train, order, k);
    %model = trainModel(Train, A_train, order, k);
else
    model = k_model(Train, A_train, order, k, gmodel);
end

train_err= zeros(size(Train,1),1);
val_err = zeros(size(Val,1),1);
% Evaluate on Train
for i = 1:size(Train,1) 
    pt = [Train(i,1:3:end)'; Train(i,2:3:end)'; Train(i,3:3:end)'];
    alpha_est = model(pt);
    alpha_real = A_train(i,:)';
    train_err(i) = sqrt(sum((alpha_est-alpha_real).^2));
end

for i = 1:size(Val,1) 
    pt = [Val(i,1:3:end)'; Val(i,2:3:end)'; Val(i,3:3:end)'];
    alpha_est = model(pt);
    alpha_real = A_val(i,:)';
    val_err(i) = sqrt(sum((alpha_est-alpha_real).^2));
end
msTrainE=mean(train_err)
msValE=mean(val_err)


end
