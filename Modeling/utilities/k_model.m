function fun = k_model(P, A, order, K, use_solver, global_model)

if nargin < 6
    global_model = trainModel(P, A, order, use_solver);
end
[num_obs, ~] = size(P);

% Devide alpha space into k sections
num_iter = 0;
Points = {};
Alphas = {};
models = {};
[assign,C] = kmeans(A, K);
old_assign = assign;
loss = zeros(num_iter,num_obs);

for k = 1:K
    Points{k} = P(assign==k,:);
    Alphas{k} = A(assign==k,:);
end

% Train K models, each on their own section
JKS = [];
for k = 1:K
    [models{k}, JK] = trainModel(Points{k}, Alphas{k}, order, use_solver);
    JKS(k,:) = reshape(JK,1,numel(JK));
end
% K = 16;
% similar = kmeans(JKS, K);
% assign = similar(assign);

for ii = 1:num_iter
    
    for k = 1:K 
        models{k} = trainModel(Points{k}, Alphas{k}, 1, use_solver);
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
        %[~, ind] = min(sum((A-global_model(pt)').^2,2));
        [~, ind] = min(sum((A-global_model(pt)').^2,2));
        m = assign(ind);
    end
mean(loss,2)
fun = @(pt) models{find_assign(global_model, pt, assign, A)}(pt); 
end