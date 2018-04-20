function fun = k_model(P, A, order, K, global_model)

if nargin < 5
    global_model = trainModel(P, A, order);
end
[num_obs, ~] = size(P);

% Devide alpha space into k sections
num_iter = 10;
Points = {};
Alphas = {};
models = {};
assign = kmeans(A, K);
old_assign = assign;
loss = zeros(num_iter,num_obs);

for k = 1:K
    Points{k} = P(assign==k,:);
    Alphas{k} = A(assign==k,:);
end

% Train K models, each on their own section

for ii = 1:num_iter
    
    for k = 1:K
        models{k} = trainModel(Points{k}, Alphas{k}, order);
    end
    
    % Find the best model for each point in each section
    
    for i = 1:size(P,1)
        res = zeros(k, size(A,2));
        pt = [P(i,1:3:end)'; P(i,2:3:end)'; P(i,3:3:end)'];
        for k = 1:K
            res(k,:) = models{k}(pt)';
        end
        [err, mdl] = min(sqrt(sum((res-A(i,:)).^2,2)));
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

for i = 1:size(P,1)
    pt = [P(i,1:3:end)'; P(i,2:3:end)'; P(i,3:3:end)'];
    A(i,:) = global_model(pt)';
end

    function m = find_assign(global_model, pt,  assign, A)
        [~, ind] = min(sqrt(sum((A-global_model(pt)').^2,2)));
        m = assign(ind);
    end
mean(loss,2)
fun = @(pt) models{find_assign(global_model, pt, assign, A)}(pt); 
end