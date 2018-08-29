% Investigate how the validation error responds to increasing the order of
% the shape-approximation

addpath('../../utilities/');
A  = csvread(strcat('alphamap_grabber.csv'));
P=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2.csv');

n = 2;
P = P(:,3*n-2:3*n);

maxO = 18;
rnds = 10;
frac = 0.7;
t_err = zeros(maxO, rnds);
v_err = zeros(maxO, rnds);

for rnd = 1:rnds

train_inds = datasample(1:size(P,1),round(frac*size(P,1)));
val_inds = setdiff(1:size(P,1),train_inds);
P_train = P(train_inds,:);
P_val = P(val_inds,:);

A_train = A(train_inds,:);
A_val = A(val_inds,:);



for order = 1:maxO
    [mod, fmod] = k_model(P_train,A_train,order,1,order~=1,0);
    
    pred_train = fmod(A_train);
    pred_val = fmod(A_val);
    
    train_err = mean(sqrt(sum((pred_train-P_train).^2,2)));
    val_err = mean(sqrt(sum((pred_val-P_val).^2,2)));
  
    
    t_err(order,rnd) = train_err;
    v_err(order,rnd) = val_err;
    
end
end
   


plot(mean(t_err,2),'b')
hold on;
plot(mean(v_err,2),'g');

h1=fill([1:size(t_err,1), size(t_err,1):-1:1],[mean(t_err,2)'-sqrt(var(t_err')),fliplr(mean(t_err,2)'+sqrt(var(t_err')))],('b'));
h2=fill([1:size(v_err,1), size(v_err,1):-1:1],[mean(v_err,2)'-sqrt(var(v_err')),fliplr(mean(v_err,2)'+sqrt(var(v_err')))],('g'));


alpha(0.1)

xlabel('Order');
ylabel('Deviation in m');

legend([h1 h2],{'Training error \pm 1std', 'Validation error \pm 1std'});


%i = 1
%scatter3(pred_train(:,i*3-2),pred_train(:,i*3-1),pred_train(:,i*3),4,'f')
%hold on;
%scatter3(pred_val(:,i*3-2),pred_val(:,i*3-1),pred_val(:,i*3),4,'f')

    