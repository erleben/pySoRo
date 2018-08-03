% Investigate how the validation error responds to increasing the order of
% the shape-approximation

addpath('../../utilities/');
A  = csvread(strcat('alphamap_grabber.csv'));
A= A./max(A);
P = A;
A=normalize(A);
P=normalize(P);

numSigma = 10;
maxSigma = 0.1;
order = 10;
K = 10;
rnds = 20;
frac = 0.7;

sigmas = linspace(0,maxSigma,numSigma);
t_err = zeros(numSigma, rnds);
v_err = zeros(numSigma, rnds);

parfor s_ind = 1:numSigma
    
    for rnd = 1:rnds
        [s_ind,rnd]
        train_inds = datasample(1:size(P,1),round(frac*size(P,1)));
        val_inds = setdiff(1:size(P,1),train_inds);
        
        
        P_train = P(train_inds,:);
        P_train = P_train +  normrnd(0,sigmas(s_ind),size(P_train));
        P_val = P(val_inds,:);
        P_val = P_val + normrnd(0,sigmas(s_ind),size(P_val));
        
        A_train = A(train_inds,:);
        A_val = A(val_inds,:);
        
        [mod, fmod] = k_model(P_train,A_train,order,K,order~=1,1);
        
        pred_train = mod(P_train);
        pred_val = mod(P_val);
        
        train_err = mean(sqrt(sum((pred_train-A_train).^2,2)));
        val_err = mean(sqrt(sum((pred_val-A_val).^2,2)));
        
        
        t_err(s_ind,rnd) = train_err;
        v_err(s_ind,rnd) = val_err;
        
    end
end

mt = mean(t_err,2);
mv = mean(v_err,2);
res = [mt,mv];
save('l10o10','res');
figure;
plot(sigmas,mean(t_err,2),'r')
hold on;
plot(sigmas,mean(v_err,2),'b');

%h1=fill([1:size(t_err,1), size(t_err,1):-1:1],[mean(t_err,2)'-sqrt(var(t_err')),fliplr(mean(t_err,2)'+sqrt(var(t_err')))],('b'))
%h2=fill([1:size(v_err,1), size(v_err,1):-1:1],[mean(v_err,2)'-sqrt(var(v_err')),fliplr(mean(v_err,2)'+sqrt(var(v_err')))],('g'))


%alpha(0.1)

xlabel('\sigma');
ylabel('Error');

legend('Training error', 'Validation error');


%i = 1
%scatter3(pred_train(:,i*3-2),pred_train(:,i*3-1),pred_train(:,i*3),4,'f')
%hold on;
%scatter3(pred_val(:,i*3-2),pred_val(:,i*3-1),pred_val(:,i*3),4,'f')

