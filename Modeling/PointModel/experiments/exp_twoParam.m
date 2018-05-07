function [msTrainE, msValE, model] = exp_twoParam(order, k, use_solver, isPoly)
% This function trains a order-ordered model, using k local models. 
% If gmodel is not specified, then a global model is made.


addpath('../../utilities/');
Alphas  = csvread(strcat('../data/alphamap.csv'));
P=load('../data/ordered_twoP.csv');

P(1:7*51,:) = [];
Alphas(1:7*51,:)=[];

Alphas  = Alphas(:,2:end);
do_val = true; 

Val = [];
if do_val
    Train_inds = datasample(1:size(Alphas,1),round(0.7*size(P,1)),'Replace', false);
    Val_inds = setdiff(1:size(Alphas,1), Train_inds);
else
    Train_inds = 1:size(Alphas,1);
end


Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);

Val = P(Val_inds,:);
A_val = Alphas(Val_inds,:);

% Train a model on the first dataset
%model = trainModel(P, Alphas, order);
model = k_model(Train, A_train, order, k, use_solver, isPoly);

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
