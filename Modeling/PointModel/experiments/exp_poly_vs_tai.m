num = 300;
order = 3;
rn = 1000;
tres = zeros(num,rn);
pres = zeros(num,rn);
res = zeros(rn,2);

A = (1:num)';

for r = 1:rn
noise = normrnd(0,0.01,num,1);


[~,tay] = trainModel(noise,A,order,false,false);
[~,poly] = trainModel(noise,A,order,false,true);

for i = 1:num
    tres(i,r) = tay(A(i));
    pres(i,r) = poly(A(i));
end

end

for r = 1:rn
    res(r, 1) = norm(tres(:,r));
    res(r, 2) = norm(pres(:,r));
end

mean(res)
% plot(A,res);
% hold on
% plot(A,noise);
% legend('Taylor approximation', 'Polynomial regression', 'Training data');
% xlabel('\Delta \alpha');
% ylabel('s(\alpha)');
