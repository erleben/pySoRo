function showConf(P,n)

figure;
X=P(1:3:end,:);
Y=P(2:3:end,:);
Z=P(3:3:end,:);
sz = 1;
for i = 1:n
j = i
p = P(j,:);
scatter3(p(1:3:end),p(2:3:end),p(3:3:end),sz);
axis([ min(X(:)) max(X(:)) min(Y(:)) max(Y(:)) min(Z(:)) max(Z(:)) ]);

hold on;
drawnow;
end
end