loss = zeros(1,10);
losss = loss;
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
[~,poly1] = trainModel(noise,A,order,1,true);

%[~,tay] = k_model(noise,A,order,1,1,0,false);
[~,poly] = k_model(noise,A,order,6,1,1,true);


tres = poly1(A);
pres = poly(A)';

loss(o) = mean((noise-pres').^2);
losss(o) =mean((noise-tres').^2);
end



plot(A,tres);
hold on
plot(A,pres);

plot(A,noise);
legend('Taylor approximation', 'Polynomial regression', 'Training data');
xlabel('\Delta \alpha');
ylabel('s(\alpha)');

