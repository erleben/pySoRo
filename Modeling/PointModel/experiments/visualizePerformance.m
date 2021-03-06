

addpath('../../utilities/');
A  = csvread(strcat('alphamap_grabber.csv'));

%P=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2_2.csv');
P=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g3.csv');

%P = P(:,3*n-2:3*n);
%A  = csvread(strcat('../data/alphamap.csv'));
%A = A(:,2:end);
%P = csvread('../data/ordered_twoP.csv');
%A = csvread('../data/alphamap.csv');
%A = A(:,2:3);

%P = csvread('../data/ordered_finger2.csv');
%A = csvread('../data/alphamap_finger.csv');
%A = A(:,2:3);

n = 4
P = P(:,3*n-2:3*n);
m = 35;
n = 29;
O = 10;


[model, fmod] = k_model(P, A, order,1, 0, 1);

alpha_est = model(P);
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
figure;
hold on;
for i  =num_p
    scatter3(p_est(:,i*3-2),p_est(:,i*3-1),p_est(:,i*3),4,'f')
end
r = 5;
p = P(datasample(1:100,10,'Replace',false),:);

%a=model(p);
%p_pred= fmod(a);
 
%for i = 1:r
%pl = [p(i,:);p_pred(i,:)];
%plot3(pl(:,1),pl(:,2),pl(:,3), 'LineWidth', 5);
%end
mean(sqrt(sum((p_est-P).^2,2)))
