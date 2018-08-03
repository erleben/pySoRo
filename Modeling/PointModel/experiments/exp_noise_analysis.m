%In this experiment, we keep all parameters fixed except for the standard
%deviation of the noise in the displacemnt matrix. 

num_sig = 50;
num_rnds = 30;

N = 2;
K = 120;

A = linspace(1,1.2,K)'*2;
pt = [(A/4).^2, flipud(A-2.2).^2];

loss_l = zeros(num_sig,1);
loss = loss_l;

p_pred = zeros(length(A),size(pt,2));
a_pred = zeros(length(A),size(A,2));

s = 0.01;

sigmas = s*linspace(0,1,num_sig);
for r = 1:num_sig
for nr = 1:num_rnds
    sigma = sigmas(r);
    noise = normrnd(0,sigma,size(pt,1), size(pt,2));
    
    [~, nmod] = trainModel(noise, A, 2, false, false);
    
    n_pred = nmod(A);
    
    loss_l(r) = loss_l(r) + mean(sqrt(sum((n_pred').^2,2)));
    loss(r) = loss(r) +  mean(sqrt(sum((noise).^2,2)));
end
end

plot(sigmas, loss);
hold on;
plot(sigmas, loss_l);
xlabel('\sigma')
ylabel('||n_{s^*}]||')
legend('Norm of noise component in training data', 'Average norm of noise component in prediction')