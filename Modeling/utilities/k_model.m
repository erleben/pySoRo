function [fun, fun_select] = k_model(P, A, order, K, use_solver, isPoly)

% Find the minimum number of configrations needed to solve for kinematics
min_conf = sum(arrayfun(@(x)nchoosek(size(A,2)+x-1,x),1:order));

if nargin < 6
    isPoly = false;
end

[num_obs, ~] = size(P);

% Devide alpha space into k sections
num_iter = 0;
Points = {};
Alphas = {};
models = {};
assign = kmeans(A(:,1), K);
old_assign = assign;
loss = zeros(num_iter,num_obs);
model_loss = zeros(K, num_obs);

for k = 1:K
    Points{k} = P(assign==k,:);
    Alphas{k} = A(assign==k,:);
end

% Train K models, each on their own section
for k = 1:K
    [models{k,1}, models{k,2}, models{k,3}, models{k,4}] = trainModel(Points{k}, Alphas{k}, order, use_solver, isPoly);
end

for ii = 1:num_iter
    
    % Find the best model for each point in each section
    
    for k = 1:K
        model_loss(k,:) = sum((models{k,1}(P')-A').^2,1);
    end
    [min_loss, assign] = min(model_loss);
    loss(ii,:) = sqrt(min_loss);
    for k = 1:K
        Points{k} = P(assign == k, :);
        Alphas{k} = A(assign == k, :);
    end
    
    for k = 1:K
        if sum(assign == k) < min_conf
            models{k,1} = @(x) inf;
            models{k,2} = @(x) inf;
            models{k,3} = @(x,y) inf;
            models{k,4} = @(x,y) inf;
        else
            [models{k,1}, models{k,2}, models{k,3}, models{k,4}] = trainModel(Points{k}, Alphas{k}, order, use_solver, isPoly);
        end
    end
    
    if isequal(assign, old_assign)
        break
    end
    old_assign = assign;
    
end

    function res = find_assign(pt, mods, I)
        if nargin < 3
            KK = size(mods,1);
            l = zeros(KK,size(pt,2));
            res = zeros(size(pt,2),2);
            for kk = 1:KK
                pred = mods{kk,1}(pt);
                l(kk,:) = sum((mods{kk,2}(pred') - pt).^2,1);
            end
            [~, mdl] = min(l,[],1);
            
            for kk = unique(mdl)
                res(mdl == kk,:) = mods{kk,1}(pt(:,mdl == kk))';
            end
            
        else
            
            KK = size(mods,1);
            l = zeros(KK,size(pt,2));
            res = zeros(size(pt,2),2);
            for kk = 1:KK
                pred = mods{kk,3}(pt, I);
                l(kk,:) = sum((mods{kk,4}(pred', I) - pt).^2,1);
            end
            [~, mdl] = min(l,[],1);
            
            for kk = unique(mdl)
                res(mdl == kk,:) = mods{kk,3}(pt(:,mdl == kk), I)';
            end
            
        end
    end

%mean(loss,2)
fun = @(pt)find_assign(pt, models);
fun_select = @(pt,I)find_assign(pt, models, I);
end