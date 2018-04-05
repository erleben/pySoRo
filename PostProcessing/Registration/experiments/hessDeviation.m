alpha = [];
for i = 1:34
    [est, est2, real]=runHessOnWhitBox(i);
    alpha = [alpha; [real, est, est2]];
end

plot(alpha(:,1));
hold on;
plot(alpha(:,2));
hold on;
plot(alpha(:,3));

legend('Real', 'fmincon', 'Solving ls');

sum(abs(alpha(:,2:3)-alpha(:,1)))