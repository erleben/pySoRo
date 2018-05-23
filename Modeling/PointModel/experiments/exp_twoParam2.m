function [msTrainE, msValE, model, model_select] = exp_twoParam(order, k, use_solver, isPoly, do_val)
% This function trains a order-ordered model, using k local models.
% If gmodel is not specified, then a global model is made.


addpath('../../utilities/');
Alphas  = csvread(strcat('alphamap_finger.csv'));
P=load('../data/ordered_finger2.csv');
P=P(:,4:6);
saveModel = true;


if nargin < 5
    do_val = false;
end

if do_val
    Train_inds = datasample(1:size(Alphas,1),round(0.8*size(P,1)),'Replace', false);
    %Train_inds = 90:size(Alphas,1)-90;
else
    Train_inds = 1:size(Alphas,1);
end
Val_inds = setdiff(1:size(Alphas,1), Train_inds);

Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);

Val = P(Val_inds,:);
A_val = Alphas(Val_inds,:);

% Train a model on the first dataset
model = k_model(Train, A_train, order, k, use_solver, isPoly);

alpha_est = model(Train');
train_err = sqrt(sum((alpha_est-A_train).^2,2));
var(alpha_est-A_train)

alpha_est = model(Val');
val_err = sqrt(sum((alpha_est-A_val).^2,2));
var(alpha_est-A_val)

msTrainE=mean(train_err)
msValE=mean(val_err)

if saveModel
    model = @(p) model(cellfun(@double,cell(p))');
    save('../../../RealTime/model.mat','model');
end


end