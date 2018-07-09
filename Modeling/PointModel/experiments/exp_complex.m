X=  0:0.01:10;
y1 = sin(X)*0.5;
y2  = X.^2;

Y = [y1', y2'];

X = normalize(X);
Y = normalize(Y);

plot3(X,Y(:,1),Y(:,2));

for o = 1:10
[model,fmodel]=k_model(Y,X',o,3,1,1);
y_est = fmodel(X');
err(o) = mean(sum((y_est-Y).^2,2))
end

hold on;
plot3(X,y_est(:,1),y_est(:,2));


O = 10;
K = 20;

for_err = zeros(O,K);
ik_err = for_err;

for o = 1:O
    for k = 1:K
        
        [model,fmodel]=k_model(Y,X',o,k,0,1);
        
        y_est = fmodel(X');
        x_est = model(Y');
        
        for_err(o,k) = mean(sqrt(sum((y_est-Y).^2,2)));
        ik_err(o,k) = mean(sqrt(sum((x_est-X').^2,2)));
    end
end

