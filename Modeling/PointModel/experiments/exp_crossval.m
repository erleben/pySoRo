% n-fold crossvalidation on number of local models vs number model order
% Warning: Takes a lot of time
folds = 5;
max_order = 6;
%gcp

%Load data
%Alphas  = csvread(strcat('../data/alphamap.csv'));
%P = load('../data/ordered_twoP.csv');
%P = P(:,19:21);


P = csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2.csv');
Alphas = csvread('alphamap_grabber.csv');
%Prune redundant shapes
%P(1:7*51,:) = [];
%Alphas(1:7*51,:)=[];
%Alphas  = Alphas(:,2:end);


%Partition into train and test
Train_inds = datasample(1:size(Alphas,1),round(0.99*size(P,1)),'Replace', false);
Test_inds = setdiff(1:size(Alphas,1), Train_inds);

Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);

Test = P(Test_inds,:);
A_Test = Alphas(Test_inds,:);

res = cell(max_order,1);
use_solver = true(max_order,1);
use_solver(1) = false;
for order = 1:max_order
    
    num_val = (folds-1)*size(Train,1)/folds;
    min_conf = sum(arrayfun(@(x)nchoosek(size(A_train,2)+x-1,x),1:order))+1;
    max_local = round(num_val*0.5/min_conf);
    
    k_sample = round([1:2:9, 12+(1:round(nthroot(max_local-12,2.2))).^2.2]);
    %k_sample = k_sample(1:2:end);
    %k_sample = 1:max_local;
    
    res{order} = zeros(length(k_sample),5);
    ind = 1;
    for k = k_sample
        perm = datasample(1:size(Train,1), size(Train,1), 'Replace', false);
        pr_fold = floor(size(perm,2)/folds);
        
        val_loss = 0;
        tr_loss = 0;
        train_time = 0;
        exec_time = 0;
        val_ind = [];
  
        for fold = 1:folds
            val_inds = (fold-1)*pr_fold+1:fold*pr_fold;
            tr_inds = setdiff(perm, val_inds);
            v = fold;
            tic;
            model = k_model(Train(tr_inds,:),A_train(tr_inds,:), order, k, use_solver(order), true);
            train_time = train_time + toc;
            
            tic;
            alpha_est = model(Train(val_inds,:));
            exec_time = exec_time + toc;
            val_loss = val_loss + sum(sqrt(sum((alpha_est-A_train(val_inds,:)).^2,2)));
             
            train_test_inds = datasample(tr_inds, length(val_inds), 'Replace', false);
            alpha_est = model(Train(train_test_inds,:));
            tr_loss = tr_loss + sum(sqrt(sum((alpha_est-A_train(train_test_inds,:)).^2,2)));

            
            
        end
        

        res{order}(ind,1) = k;
        res{order}(ind,2) = tr_loss/(pr_fold*folds);
        res{order}(ind,3) = val_loss/(pr_fold*folds);
        res{order}(ind,4) = train_time/folds;
        res{order}(ind,5) = exec_time/folds;

        ind = ind + 1;
        [order,k]
    end
   
end
save('res_5f_two_p.mat','res');
