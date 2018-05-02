function fun = k_model(P, A, order, K, use_solver)

[num_obs, ~] = size(P);

% Devide alpha space into k sections
num_iter = 5;
Points = {};
Alphas = {};
models = {};
assign = kmeans(A, K);
old_assign = assign;
loss = zeros(num_iter,num_obs);
%old_err = inf;

for k = 1:K
    Points{k} = P(assign==k,:);
    Alphas{k} = A(assign==k,:);
end

% Train K models, each on their own section
JKS = [];
for k = 1:K
    [models{k,1}, models{k,2}] = trainModel(Points{k}, Alphas{k}, order, use_solver);
end

for ii = 1:num_iter
    
    % Find the best model for each point in each section
    
    for i = 1:size(P,1)
        res = zeros(k, size(A,2));
        pt = [P(i,1:3:end)'; P(i,2:3:end)'; P(i,3:3:end)'];
        for k = 1:K
            res(k,:) = models{k,1}(pt)';
        end
        [err, mdl] = min(sqrt(sum((res-A(i,:)).^2,2)));
        loss(ii,i) = err; 
        assign(i) = mdl;
    end
    
    for k = 1:K
        Points{k} = P(assign == k, :);
        Alphas{k} = A(assign == k, :);
    end
    
    for k = 1:K 
        [models{k,1}, models{k,2}] = trainModel(Points{k}, Alphas{k}, order, use_solver);
    end
    
    if isequal(assign, old_assign)
        break
    end
    old_assign = assign;
    
end

    function mdl = find_assign(pt, mods)
        KK = size(mods,1);
        l = zeros(KK,1);
        for kk = 1:KK
            pred = mods{kk,1}(pt);
            l(kk,1) = norm(mods{kk,2}(pred') - pt);
        end
        [~, mdl] = min(l);
            
    end

mean(loss,2) 
fun = @(pt) models{find_assign(pt, models),1}(pt); 
end