function fun = k_model(P, A, order, K, global_model)

[num_obs, ~] = size(P);

% Devide alpha space into k sections
num_iter = 100;
Points = {};
Alphas = {};
models = {};
assign = zeros(1,num_obs);
old_assign = assign;
loss = zeros(num_iter,num_obs);
chunk = round(num_obs/K);

for k = 1:K
    if k == K
        Points{k} = P((k-1)*chunk+1:end,:);
        Alphas{k} = A((k-1)*chunk+1:end,:);
    else
        Points{k} = P((k-1)*chunk+1:k*chunk,:);
        Alphas{k} = A((k-1)*chunk+1:k*chunk,:);
    end
end

% Train K models, each on their own section

for ii = 1:num_iter
    
    for k = 1:K
        models{k} = trainModel(Points{k}, Alphas{k}, order);
    end
    
    % Find the best model for each point in each section
    
    for i = 1:size(P,1)
        res = zeros(1,k);
        pt = [P(i,1:3:end)'; P(i,2:3:end)'; P(i,3:3:end)'];
        for k = 1:K
            alp_est = models{k}(pt);
            res(k) = alp_est(1);
        end
        [err, mdl] = min(abs(res-A(i,3)));
        loss(ii,i) = err;
        assign(i) = mdl;
    end
    
    for k = 1:K
        Points{k} = P(assign == k, :);
        Alphas{k} = A(assign == k, :);
    end
    
    %sum(assign==old_assign)
    if isequal(assign, old_assign)
        break
    end
    old_assign = assign;
end

%mean(loss,2)
fun = @(pt) models{interp1(A(:,3)', assign, global_model(pt),'nearest', 'extrap')}(pt); 
end