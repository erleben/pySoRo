function [msTrainE, msValE, model] = exp_twoParam(order, k, use_solver, isPoly, do_val)
% This function trains a order-ordered model, using k local models.

% Save the model for real time applications
saveModel = true;
name = '../../../RealTime/model3.mat';

addpath('../../utilities/');
Alphas  = csvread(strcat('D:\demo2\alphamap.csv'));
P=load('C:\Users\kerus\Documents\GitHub\pySoRo\PostProcessing\outputOrder\ordered_demo2.csv');

%P(1:13*51,:) = [];
%Alphas(1:13*51,:)=[];
P=P(:,7:end);
Alphas  = Alphas(:,3:end);

 m1=numel(unique(Alphas(:,2)));
 AA = [];
 for i  =1:m1
     AA = [AA;Alphas(i:m1:end,:)];
 end
 Alphas = AA;

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
fst =@(x) x(1,:)
msTrainE=mean(train_err) 

if saveModel
    model = @(p) fst(model(p));
    save(name,'model');
end

end
