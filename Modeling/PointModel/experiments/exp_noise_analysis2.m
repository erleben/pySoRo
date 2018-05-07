%In this experiment, we keep all parameters fixed except for the standard
%deviation of the noise in the displacemnt matrix.


A = (1:0.001:1.2)'*2;
%pt = [(A/4).^2, flipud(A-2.2).^2];
pt = [(A/4).^2];

p_pred = zeros(length(A),size(pt,2));
num_rn = 1;
s = 0.0;
S = 0:0.01:0.01;
p_dev = zeros(size(A,1),length(S));
n_dev = p_dev;
explt = p_dev;
ind = 1;
legendinfo={};
for s = S
    for nr = 1:num_rn
        
        noise = normrnd(0, s, size(pt,1), size(pt,2));
        [model, fmodel] = trainModel(pt+noise, A, 2, false, true);
        [~, nmodel] = trainModel(noise,A,2,false, true);
        
        for i = 1:length(A)
            p_pred(i,:) = fmodel(A(i));
            n_pred(i,:) = nmodel(A(i));
        end
        explt(:,ind) = explt(:,ind)+s*sqrt(length(A))*(1/min(svd(A-A(1))))*(A-A(1)) + sqrt(2/pi)*s/2;
        n_dev(:,ind) = n_dev(:,ind) + n_pred;
        p_dev(:,ind) = p_dev(:,ind) + sqrt(sum((p_pred-pt).^2,2));
        if nr == 1
            NN = norml;
        end
    end
    legendInfo{ind} = ['Standard dev: ' num2str(s)];
    ind = ind +1;
end
p_dev = p_dev/num_rn;
n_dev = n_dev/num_rn;
explt = explt/num_rn;

for ind = 1:length(S)
    plot(A-A(1),p_dev(:,ind));
    hold on;
end
legend(legendInfo);
xlabel('\Delta \alpha')
ylabel('norm of deviation')
%plot(A-A(1),n_dev);
plot(A-A(1),explt);

