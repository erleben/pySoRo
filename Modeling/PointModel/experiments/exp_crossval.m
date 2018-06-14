%crossvalidation on number of models 
folds = 4;
max_order = 6;
gcp

%Load data
Alphas  = csvread(strcat('../data/alphamap.csv'));
P = load('../data/ordered_twoP.csv');

%Prune redundant shapes
P(1:13*51,:) = [];
Alphas(1:13*51,:)=[];
Alphas  = Alphas(:,2:end);

%Partition into train and test
Train_inds = datasample(1:size(Alphas,1),round(0.50*size(P,1)),'Replace', false);
Test_inds = setdiff(1:size(Alphas,1), Train_inds);

Train = P(Train_inds,:);
A_train = Alphas(Train_inds,:);

Test = P(Test_inds,:);
A_Test = Alphas(Test_inds,:);

res = {};
use_solver = false;

parfor order = 1:max_order

    num_val = (folds-1)*size(Train,1)/folds;
    min_conf = sum(arrayfun(@(x)nchoosek(size(A_train,2)+x-1,x),1:order))+1;
    max_local = round(num_val/min_conf);
    
    k_sample = [1:9, 10+(1:round(sqrt(max_local-10))).^2];
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
        
        for fold = 1:folds
            val_inds = (fold-1)*pr_fold+1:fold*pr_fold;
            tr_inds = setdiff(perm, val_inds);
            
            tic;
            model = k_model(Train(tr_inds,:),A_train(tr_inds,:), order, k, use_solver, true);
            train_time = train_time + toc;
            
            tic;
            alpha_est = model(Train(val_inds,:)');
            exec_time = exec_time + toc;
            val_loss = val_loss + sum(sqrt(sum((alpha_est-A_train(val_inds,:)).^2,2)));
            
            alpha_est = model(Train(tr_inds,:)');
            tr_loss = tr_loss + sum(sqrt(sum((alpha_est-A_train(tr_inds,:)).^2,2)));
            
            
        end
        

        res{order}(ind,1) = k;
        res{order}(ind,2) = tr_loss/(length(tr_inds)*folds);
        res{order}(ind,3) = val_loss/(length(val_inds)*folds);
        res{order}(ind,4) = train_time/folds;
        res{order}(ind,5) = exec_time/folds;
        ind = ind + 1;
        order,k
    end
   
end
save('res2.mat','res');
figure;
Train = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Train(1:numel(res{d}(:,1)),d) = res{d}(:,2);
end
cmax = max(Train(:));
Tr = Train;
Tr(Train==0)=1000;
cmin = min(Tr(:));
imagesc(log(Tr));
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
colormap hot;
xlabel('order');
ylabel('local models')
title('Training');
hcb = colorbar('FontSize',11,'YTick',log([round(cmin) :10,12:6: cmax]) ,'YTickLabel',[round(cmin) :10,12:6: cmax]);
caxis(log([cmin cmax-8]));
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Loss');

figure;
Val = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Val(1:numel(res{d}(:,1)),d) = res{d}(:,3);
end
cmax = max(Val(:));
V = Val;
V(Val==0)=1000;
cmin = min(V(:));
imagesc(log(V));
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
%caxis([cmin cmax]);
colormap hot;
xlabel('order');
ylabel('local models')
title('Validation');
hcb = colorbar('FontSize',11,'YTick',log([round(cmin) :2:14,16:6: cmax]) ,'YTickLabel',[round(cmin) :2:14,16:6: cmax]);
caxis(log([cmin cmax-8]));
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Loss');

figure;
Time = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Time(1:numel(res{d}(:,1)),d) = res{d}(:,4);
end

cmax = max(Time(:));
cmin = min(Time(:));
Ti = Time;
Ti(Ti==0)=1000;
imagesc(Ti);
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
hcb = colorbar;
caxis([cmin cmax+0.5]);
colormap hot;
xlabel('order');
ylabel('local models')
title('Time');
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','Time (s)');


figure;
Time = zeros(length(res{1}(:,1)),max_order);
for d = 1:max_order
    Time(1:numel(res{d}(:,1)),d) = res{d}(:,5);
end

cmax = max(Time(:));
cmin = min(Time(:));
Ti = Time;
Ti(Ti==0)=1000;
imagesc(Ti);
yticks(1:2:length(res{1}));
yticklabels(int2str(res{1}(1:2:end,1)));
hcb = colorbar;
caxis([cmin cmax+0.5]);
colormap hot;
xlabel('order');
ylabel('local models')
title('Time');
colorTitleHandle = get(hcb,'Title');
set(colorTitleHandle ,'String','ExecutionTime (s)');

% Find best params for validaion:
[k_ind,d] = find(V==min(V(:)));
V(k_ind,d)
k = res{1}(k_ind,1);
model = k_model(P(Train_inds,:),Alphas(Train_inds,:), d, k, false, true);
alpha_est = model(P(Test_inds,:)');
test_loss = sqrt(sum((alpha_est-Alphas(Test_inds,:)).^2,2));

% Find best params training:
[k_ind,d] = find(Tr==min(Tr(:)));
Tr(k_ind,d)
k = res{1}(k_ind,1);
model = k_model(P(Train_inds,:),Alphas(Train_inds,:), d, k, false, true);
alpha_est = model(P(Test_inds,:)');
train_loss = sqrt(sum((alpha_est-Alphas(Test_inds,:)).^2,2));