% Comparison of Taylor approximation and polynomial regression of
% different orders

loss_poly = zeros(1,10);
loss_tay = loss_poly;
noise = rand(100,1)*10000;
noise(datasample(1:length(noise),1,'Replace',false)) = 0;
for o = 1:10

num = 100;
order = o;

res = zeros(1,2);

A = ((1:num)+ rand(1,num)*0)';
X = (A-num/2).^2;



noise = noise + X;

%[~,tay] = trainModel(noise,A,order,0,false);
[pmod,poly1] = trainModel(noise,A,order,1,0,1);

%[~,tay] = k_model(noise,A,order,1,1,0,false);
[tmod,poly] = k_model(noise,A,order,1,0,0);


pres = poly1(A);
tres = poly(A)';

IKpres = pmod(noise);
IKtres = tmod(noise);

loss_poly(o) = mean(sqrt(sum((noise-pres').^2,2)));
loss_tay(o) =mean(sqrt(sum((noise-tres').^2,2)));

loss_poly(o) = mean(sqrt(sum((A-IKpres').^2,2)));
loss_tay(o) =mean(sqrt(sum((A-IKtres').^2,2)));

end



plot(A,tres);
hold on
plot(A,pres);

plot(A,noise);
legend('Taylor approximation', 'Polynomial regression', 'Training data');
xlabel('\Delta \alpha');
ylabel('s(\alpha)');

