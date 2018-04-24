alpha = [];

for i = 1:99
    [est, est2, real]=runHessOnWhitBox(i);
    alpha = [alpha; [real, est, est2]];
end

figure;
plot(alpha(:,1));
hold on;
plot(alpha(:,2));
hold on;
plot(alpha(:,3));

legend('Real', 'fmincon', 'Solving ls');

mean(abs(alpha(:,2:3)-alpha(:,1)))