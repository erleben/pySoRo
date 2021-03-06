function [msTrainE, msValE, model] = exp_twoParam(order, k, use_solver, isPoly, do_val)
% This function trains a order-ordered model, using k local models.

% Save the model for real time applications
saveModel = false;
name = '../../../RealTime/model.mat';

addpath('../../utilities/');
Alphas  = csvread(strcat('../data/alphamap.csv'));
P=load('../data/ordered_twoP.csv');

P(1:13*51,:) = [];
Alphas(1:13*51,:)=[];

Alphas  = Alphas(:,2:end);

if nargin < 5
    do_val = false;
end

if do_val
    Train_inds = datasample(1:size(Alphas,1),round(0.7*size(P,1)),'Replace', false);
else
    Train_inds = 1:size(Alphas,1);
end
Val_inds = setdiff(1:size(Alphas,1), Train_inds);

Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);

Val = P(Val_inds,:);
A_val = Alphas(Val_inds,:);

% Train a model on the training data
model = k_model(Train, A_train, order, k, use_solver, isPoly,1);

alpha_est = model(Train);
train_err = sqrt(sum((alpha_est-A_train).^2,2));
var(alpha_est-A_train)

if do_val
    alpha_est = model(Val);
    val_err = sqrt(sum((alpha_est-A_val).^2,2));
    var(alpha_est-A_val)
    msValE=mean(val_err)
else
    msValE = -1;
end

msTrainE=mean(train_err)

if saveModel
    model = @(p) model(cellfun(@double,cell(p))');
    save(name,'model');
end

end
