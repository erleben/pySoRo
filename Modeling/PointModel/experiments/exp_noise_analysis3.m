%In this experiment, we keep all parameters fixed except for the standard
%deviation of the noise in the displacemnt matrix. 

num_orders = 60;
num_rnds = 20;

N = 2;
K = 50;

A = linspace(1,1.2,K)'*2;
pt = [(A/4).^2, flipud(A-2.2).^2];

loss_l = zeros(num_orders,1);
loss = loss_l;

p_pred = zeros(length(A),size(pt,2));
a_pred = zeros(length(A),size(A,2));

s = 0.01;

for nr = 1:num_rnds
    noise = normrnd(0,s,size(pt,1), size(pt,2));
for o = 1:num_orders

    
    
    [~, nmod] = trainModel(noise+pt, A, o, false, true);
    
    n_pred = nmod(A);
    
    loss_l(o) = loss_l(o) + mean(sqrt(sum((n_pred').^2,2)));
    loss(o) = loss(o) +  mean(sqrt(sum((noise).^2,2)));
end
end

