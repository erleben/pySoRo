function [msTrainE, msValE, model] = exp_twoParam(order, k, use_solver, isPoly, do_val)
% This function trains a order-ordered model, using k local models. 
% If gmodel is not specified, then a global model is made.


addpath('../../utilities/');
Alphas  = csvread(strcat('alphamap_finger.csv'));
P=load('../data/ordered_finger2.csv');

%Alphas  = csvread(strcat('../data/alphamap.csv'));
%P=load('../data/ordered_twoP.csv');

%P(1:13*51,:) = [];
%Alphas(1:13*51,:)=[];



% Alphas  = Alphas(:,2:end);
% m1=numel(unique(Alphas(:,2)));
% AA = [];
% for i  =1:m1
%     AA = [AA;Alphas(i:m1:end,:)];
% end
% Alphas = AA;
if nargin < 5
    do_val = true; 
end

if do_val
    Train_inds = datasample(1:size(Alphas,1),round(0.5*size(P,1)),'Replace', false);
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

alpha_est = model(Val');
val_err = sqrt(sum((alpha_est-A_val).^2,2));


msTrainE=mean(train_err)
msValE=mean(val_err) 


end
