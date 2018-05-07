%In this experiment, we keep all parameters fixed except for the standard
%deviation of the noise in the displacemnt matrix. 

K = 100;
A = (1:0.001:1.2)'*2;
pt = [(A/4).^2, flipud(A-2.2).^2];
norml = zeros(K,1);
expl = norml;
explt =expl;
expa=expl;
norma = expl;
p_pred = zeros(length(A),size(pt,2));
a_pred = zeros(length(A),size(A,2));
num_rn = 5;
s = 0.01;

sigmas = s*(1:K)/K;

for nr = 1:num_rn
    for r = 1:K
        sigma = sigmas(r);
        noise = normrnd(0,sigma,size(pt,1), size(pt,2));
        [model, fmodel] = trainModel(pt+noise, A, 2, false, false);
        
        
        for i = 1:length(A)
            p_pred(i,:) = fmodel(A(i));
            a_pred(i) = model(pt(i,:));
        end
        norml(r)=norml(r)+norm(p_pred-pt);
        explt(r) = explt(r)+sigma*sqrt(length(A))*(1/min(svd(A-A(1))))*norm(A-A(1)) + sigma/2;
        norma(r) = norma(r) + norm(a_pred-A);
        %explt(r) = explt(r)+norm(noise)*(1/min(svd(A)))*norm(A);
        %expl(r) = expl(r)+norm((noise'*(A*A'\A))*A);
        expa(r) = expa(r) + (norm(pt)/min(svd(noise)))* norm(A);
    end
    if nr == 1
        NN = norml;
    end
end

explt = explt/num_rn;
norml=norml/num_rn;

plot(sigmas,norml);
hold on;
plot(sigmas,NN);
plot(sigmas,explt);
legend('Average observed loss: norm(n_b), 30 repetitions','Observed loss: norm(n_b), 1 repetition', 'Upper bound: E[norm(n_b)]');
xlabel('\sigma')
ylabel('norm of deviation')

figure;
%plot(norma/num_rn);

plot(p_pred(:,1),p_pred(:,2));
hold on;
npt = pt + noise;
sz= 4;
scatter(npt(:,1),npt(:,2), sz,'r','f');
plot(pt(:,1),pt(:,2));
legend('Predicted', 'With noise', 'True');
xlabel('x_1');
ylabel('x_2');