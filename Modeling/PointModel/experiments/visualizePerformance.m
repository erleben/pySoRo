

addpath('../../utilities/');
A  = csvread(strcat('alphamap_grabber.csv'));
P=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2_2.csv');


[model, fmod] = k_model(P, A, 1, 5, false, true);

alpha_est = model(P');
p_est = fmod(A);

err = sqrt(sum((alpha_est-A).^2,2));
s_err  = sqrt(sum((p_est-P).^2,2));

figure;
subplot(2,2,1);
scatter3(A(:,1), A(:,2), err);
title('err(alpha)');

subplot(2,2,2);
scatter3(A(:,1), A(:,2), s_err);
title('serr(alpha)');

subplot(2,2,3);
imagesc(reshape(err,35,29))

subplot(2,2,4);
imagesc(reshape(s_err,35,29));
title('serr(alpha)');

figure;
scatter3(P(:,1),P(:,2),P(:,3),4,'f')

hold on;
scatter3(p_est(:,1),p_est(:,2), p_est(:,3),4,'f')

r = 20;

p = P(floor(rand(r,1)*1000),:)+ 0.03*(rand(r,size(P,2))-0.3);
a=model(p');
p_pred= fmod(a);

for i = 1:r
pl = [p(i,:);p_pred(i,:)];
plot3(pl(:,1),pl(:,2),pl(:,3), 'LineWidth', 5);
end

