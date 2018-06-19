

addpath('../../utilities/');
A  = csvread(strcat('alphamap_grabber.csv'));
pm =[];
A(rm,:) = [];
AA = A;
P=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2_2.csv');
P(rm,:) = [];
PP = P;


a_mean = mean(A);
p_mean = mean(P);
a_std = std(A-a_mean);
p_std = std(P-p_mean);
A = (A-mean(A))./std(A-mean(A));
P = (P-mean(P))./std(P-mean(P));

%A  = csvread(strcat('../data/alphamap.csv'));
%A = A(:,2:end);
%P = csvread('../data/ordered_twoP.csv');
m = 35;
n = 29;

[model, fmod] = k_model(P, A, 4,1, 1, true);

alpha_est = model(P');
p_est = fmod(A);

alpha_est = alpha_est.*a_std+a_mean;
p_est = p_est.*p_std+p_mean;

err = sqrt(sum((alpha_est-AA).^2,2));
s_err  = sqrt(sum((p_est-PP).^2,2));

figure;
subplot(2,2,1);
scatter3(A(:,1), A(:,2), err);
title('err(alpha)');

subplot(2,2,2);
scatter3(A(:,1), A(:,2), s_err);
title('serr(alpha)');

%subplot(2,2,3);
%imagesc(reshape(err,m,n))

%subplot(2,2,4);
%imagesc(reshape(s_err,m,n));
%title('serr(alpha)');

num_p = 1:size(P,2)/3;
num_p = 1;
figure;
hold on;
for i = num_p
    scatter3(P(:,i*3-2),P(:,i*3-1),P(:,i*3),4,'f')
end

figure
hold on;
for i  =num_p
    scatter3(p_est(:,i*3-2),p_est(:,i*3-1),p_est(:,i*3),4,'f')
end
r = 20;

p = P(floor(rand(r,1)*1000),:)+ 0.04*(rand(r,size(P,2))-0.3);
a=model(p');
p_pred= fmod(a);

for i = 1:r
pl = [p(i,:);p_pred(i,:)];
plot3(pl(:,1),pl(:,2),pl(:,3), 'LineWidth', 5);
end

