function [msTrainE, msValE, model] = exp_twoParam2(order, k, use_solver, isPoly, do_val, bound)
% This function trains a order-ordered model, using k local models.
% If gmodel is not specified, then a global model is made.

if nargin < 6
    bound = -1;
end

addpath('../../utilities/');
Alphas  = csvread(strcat('alphamap_grabber.csv'));
P=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2_2.csv');
P = P(:,4:end);

%P =csvread('../../../PostProcessing/outputOrder/ordered_finger.csv');
%P = P(:,1:3);
%Alphas = csvread('../data/alphamap_finger.csv');

%Alphas = Alphas(:,2:3);
%Alphas  = csvread(strcat('../data/alphamap.csv'));
%Alphas = Alphas(:,2:3);
%P=csvread('../data/ordered_twoP.csv');
%P(1:13*51,:) = [];
%Alphas(1:13*51,:)=[];
%P=P(:,4:6);

%Alphas  = Alphas(:,2:end);
%  m1=numel(unique(Alphas(:,2)));
%  AA = [];
%  for i  =1:m1
%      AA = [AA;Alphas(i:m1:end,:)];
%  end
%  Alphas = AA;


saveModel = false;


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
[model,fmodel] = k_model(Train, A_train, order, k, use_solver, isPoly, bound);

%pred = fmodel(A_train);
%train_err = (sum((pred-Train).^2,2));

%pred = fmodel(A_val);
%val_err = (sum((pred-Val).^2,2));

alpha_est = model(Train');

train_err = sqrt(sum((alpha_est-A_train).^2,2));


scatter(alpha_est(:,1),alpha_est(:,2))

if do_val
    alpha_est = model(Val');
    val_err = sqrt(sum((alpha_est-A_val).^2,2));
    msValE=mean(val_err)
end
msTrainE=mean(train_err)


if saveModel
    model = @(p) model(cellfun(@double,cell(p))');
    save('../../../RealTime/model.mat','model');
end


end
