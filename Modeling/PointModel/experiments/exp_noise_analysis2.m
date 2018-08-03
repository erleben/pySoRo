%In this experiment, we keep all parameters fixed except for the standard
%deviation of the noise in the displacemnt matrix. 

num_sig = 50;
num_rnds = 30;

N = 2;
K = 100;

A = linspace(1,1.2,K)'*2;
pt = [(A/4).^2, flipud(A-2.2).^2];
pt = zeros(size(pt));

loss_1 = zeros(num_sig,1);
loss_many = loss_1;
loss_many_alt =loss_many;

p_pred = zeros(length(A),size(pt,2));
a_pred = zeros(length(A),size(A,2));

s = 0.01;

sigmas = s*linspace(0,1,num_sig);

for nr = 1:num_rnds
    for r = 1:num_sig
        r, nr
        sigma = sigmas(r);
        noise = normrnd(0,sigma,size(pt,1), size(pt,2));
        [model, fmodel] = trainModel(pt+noise, A, 2, false, false);
        [~, nmod] = trainModel(noise, A, 2, false, false);
        [~, rmod] = trainModel(pt, A, 2, false, false);
 
        p_pred = fmodel(A);
        ttt = nmod(A)+ rmod(A);
        a_pred = model(pt);
        loss_1(r)=loss_1(r)+norm(p_pred-pt');
        loss_many_alt(r) = loss_many_alt(r)+sigma*sqrt(length(A))*(1/min(svd(A-A(1))))*norm(A-A(1)) + sigma/2;
        %loss_many(r) = loss_many(r) + mean(sigma*(sqrt(6*N*K)/min(svd(A)).*abs(A) + sqrt(2/pi)));
        loss_many(r) = loss_many(r) + mean(sigma*(sqrt(6*N*K)/min(svd(makeAlpha(A',2,0))).*sqrt(sum(makeAlpha(A',2,0),1).^2)' + sqrt(2/pi)));
        %loss_many(r) = loss_many(r) + sigma*norm(pt'*pinv(makeAlpha(A',2,0))*norm(makeAlpha(A',2,0));

        
    end
    if nr == 1
        NN = loss_1;
    end
end

loss_many_alt = loss_many_alt/num_rnds;
loss_many = loss_many/num_rnds;
loss_1=loss_1/num_rnds;

plot(sigmas,loss_1);
hold on;
plot(sigmas,NN);
plot(sigmas,loss_many);
legend('Average observed loss: norm(n_b), 30 repetitions','Observed loss: norm(n_b), 1 repetition', 'Upper bound: E[norm(n_b)]');
xlabel('\sigma')
ylabel('norm of deviation')

figure;
%plot(norma/num_rn);

plot(p_pred(1,:),p_pred(2,:));
hold on;
npt = pt + noise;
sz= 4;
scatter(npt(:,1),npt(:,2), sz,'r','f');
plot(pt(:,1),pt(:,2));
legend('Predicted', 'With noise', 'True');
xlabel('x_1');
ylabel('x_2');

