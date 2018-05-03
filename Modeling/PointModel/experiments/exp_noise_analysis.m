A = (1:1000)'*2;
pt = (A/4);
norml = zeros(100,1);
expl = norml;
explt =expl;
expa=expl;
norma = expl;
p_pred = zeros(length(A),size(pt,2));
a_pred = zeros(length(A),1);
num_rn = 4;
for nr = 1:num_rn
    for r = 1:100
        sigma = 0.05*r/100;
        noise = normrnd(0,sigma,length(pt),1);
        [model, fmodel] = trainModel(pt+noise, A, 1, false);
        
        
        for i = 1:length(A)
            p_pred(i,:) = fmodel(A(i));
            a_pred(i) = model(pt(i,:));
        end
        norml(r)=norml(r)+norm(p_pred-pt);
        explt(r) = explt(r)+sigma*sqrt(length(A))*(1/min(svd(A)))*norm(A);
        norma(r) = norma(r) + norm(a_pred-A);
        %explt(r) = explt(r)+norm(noise)*(1/min(svd(A)))*norm(A);
        %expl(r) = expl(r)+norm((noise'*(A*A'\A))*A);
        expa(r) = expa(r) + (norm(pt)/min(svd(noise)))* norm(A);
    end
end
%expl=expl/num_rn;
explt = explt/num_rn;
norml=norml/num_rn;
plot(norml);
hold on;
%plot(expl);
plot(explt);
legend('Observed loss', 'Expected loss', 'Expected tight');

figure;
plot(norma/num_rn);