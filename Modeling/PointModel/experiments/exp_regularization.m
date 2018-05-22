    function [msTrainE, msValE, model, model_select] = exp_twoParam(order, k, use_solver, isPoly, do_val)

addpath('../../utilities/');
Alphas  = csvread(strcat('alphamap_finger.csv'));
[Alphas_norm, normParam] = forwNorm(Alphas);
P=load('../data/ordered_finger2.csv');

if nargin < 5
    do_val = false;
end

if do_val
    Train_inds = datasample(1:size(Alphas,1),round(0.4*size(P,1)),'Replace', false);
    %Train_inds = 90:size(Alphas,1)-90;
else
    Train_inds = 1:size(Alphas,1);
end
Val_inds = setdiff(1:size(Alphas,1), Train_inds);

Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);
A_train_norm = Alphas_norm(Train_inds,:);


Val = P(Val_inds,:);
A_val = Alphas(Val_inds,:);
A_val_norm = Alphas_norm(Val_inds,:);


% Train a model on the first dataset
model = k_model(Train, A_train_norm, order, k, use_solver, isPoly);

alpha_est = backNorm(model(Train'), normParam);
train_err = sqrt(sum((alpha_est-A_train).^2,2));

alpha_est = backNorm(model(Val'), normParam);
val_err = sqrt(sum((alpha_est-A_val).^2,2));

msTrainE=mean(train_err)
msValE=mean(val_err)

    function [A, normParam] = forwNorm(A, oldNormParam)
        if nargin < 2
            minA = min(A,[],1);
            A = A - minA;
            maxA = max(A,[],1);
            A = A./maxA;
            normParam.minA = minA;
            normParam.maxA = maxA;
        else
            A = (A-oldNormParam.minA')./oldNormParam.maxA';
        end
    end

    function A = backNorm(A, normParam)
        A = A.*normParam.maxA+normParam.minA;
    end

end






