%crossvalidation on number of models 
folds = 4;
max_order = 8;

%Load data
Alphas  = csvread(strcat('../data/alphamap.csv'));
P = load('../data/ordered_twoP.csv');

%Prune redundant shapes
P(1:7*51,:) = [];
Alphas(1:7*51,:)=[];
Alphas  = Alphas(:,2:end);

%Partition into train and test
Train_inds = datasample(1:size(Alphas,1),round(0.75*size(P,1)),'Replace', false);
Test_inds = setdiff(1:size(Alphas,1), Train_inds);

Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);

Test = P(Test_inds,:);
A_Test = Alphas(Test_inds,:);

res = {};

for order = 1:max_order
    num_val = (folds-1)*size(Train,1)/folds;
    min_conf = sum(arrayfun(@(x)nchoosek(size(A_train,2)+x-1,x),1:order))+1;
    max_local = num_val/min_conf;
    
    k_sample = [1:9, 10+(1:round(sqrt(max_local-10))).^2];
    res{order} = zeros(length(k_sample),4);
    ind = 1;
    for k = k_sample
        perm = datasample(1:size(Train,1), size(Train,1), 'Replace', false);
        pr_fold = floor(size(perm,2)/folds);
        
        val_loss = 0;
        tr_loss = 0;
        time = 0;
        
        for fold = 1:folds
            val_inds = (fold-1)*pr_fold+1:fold*pr_fold;
            tr_inds = setdiff(perm, val_inds);
            
            tic;
            model = k_model(Train(tr_inds,:),A_train(tr_inds,:), order, k, false, true);
            time = time + toc;
            
            for v = val_inds
                pt = [Train(v,1:3:end)'; Train(v,2:3:end)'; Train(v,3:3:end)'];
                val_loss = val_loss + norm(model(pt)-A_train(v,:)');
            end
            
            for t = tr_inds
                pt = [Train(t,1:3:end)'; Train(t,2:3:end)'; Train(t,3:3:end)'];
                tr_loss = tr_loss + norm(model(pt)-A_train(t,:)');
            end
            
        end
        

        res{order}(ind,1) = k;
        res{order}(ind,2) = tr_loss/(length(tr_inds)*folds);
        res{order}(ind,3) = val_loss/(length(val_inds)*folds);
        res{order}(ind,4) = time/folds;
        ind = ind + 1;
            
    end
end


% Train = zeros(length(1:2:140),6);
% for d = 1:6
%     Train(round(res{d}(:,1)/2),d) = res{d}(:,2);
% end
% Val = zeros(length(1:2:140),6);
% for d = 1:6
%     Val(round(res{d}(:,1)/2),d) = res{d}(:,2);
% end
% 
% Time = zeros(length(1:2:140),6);
% for d = 1:6
%     Time(round(res{d}(:,1)/2),d) = res{d}(:,2);
% end

Train = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Train(1:numel(res{d}(:,1)),d) = res{d}(:,2);
end
