function [msTrainE, msValE, model] = exp_twoParam(order, k, use_solver, gmodel)

%Alphas  = csvread(strcat('alphamap.csv'));
%P=load('../ordered_twoP.csv');

%P(1:7*51,:) = [];
%Alphas(1:7*51,:)=[];
%[mdist, varper, projected, mn, U, P] = findModes(P, 18);
P = load('points.mat');
P=P.P;
Alphas = load('alphas.mat');
Alphas = Alphas.Alphas;
%Alphas  = Alphas(:,2:end);
do_val = true; 
%[P,Alphas] = reduceData(P,Alphas);
Val = [];
if do_val
    Train_inds = datasample(1:size(Alphas,1),round(0.8*size(P,1)),'Replace', false);
    %iii = 1;
    %Val = (P(iii:51:end,:)+P(iii:51:end,:))/2;
    %A_val = (Alphas(iii:51:end,:)+Alphas(iii:51:end,:))/2;
    Val_inds = setdiff(1:size(Alphas,1), Train_inds);
else
    Train_inds = 1:size(Alphas,1);
end


Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);

Val = P(Val_inds,:);
A_val = Alphas(Val_inds,:);

addpath('../../Registration/experiments');

% Train a model on the first dataset
%model = trainModel(P, Alphas, order);
if nargin < 4
    model = k_model(Train, A_train, order, k, use_solver);
    model = k_model(Train, A_train, order, k, use_solver, model);
    %model = trainModel(Train, A_train, order, use_solver);
else
    model = k_model(Train, A_train, order, k, use_solver, gmodel);
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
