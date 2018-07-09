function [fun, forward_fun] = k_model(P, A, order, K, use_solver, isPoly, use_regtree)

if nargin < 7
    use_regtree = use_solver;
end
% Find the minimum number of configrations needed to solve for kinematics
min_conf = sum(arrayfun(@(x)nchoosek(size(A,2)+x-1,x),1:order));

if nargin < 6
    isPoly = false;
end

% Divide alpha space into k sections
[assign, cent] = kmeans(A, K); 
assign_mod = fitctree(P,assign);
mean(assign_mod.predict(P)==assign)

Points = cell(1,K);
Alphas = cell(1,K);
models = cell(K,2);

dist_mat = pdist2(cent,A);
num_in_local = assign;
for k = 1:K
    num = sum(assign == k);
    nn=round(sqrt(num)+1)^2;
    [~, inds] = mink(dist_mat(k,:),nn);
    Points{k} = P(inds,:);
    Alphas{k} = A(inds,:);
    num_in_local(k) = nn;
    %Points{k} = P(assign==k,:);
    %Alphas{k} = A(assign==k,:);
end

% Train K models, each on their own section
for k = 1:K
    if num_in_local(k)<min_conf
        models{k,1} = @(pt) repmat(cent(k,:)',1,size(pt,2));
        models{k,2} = @(a)  repmat(mean(P(assign==k,:))',size(a,2),1);
    else
        [models{k,1}, models{k,2}] = trainModel(Points{k}, Alphas{k}, order, use_solver, isPoly); 
    end
end
 

    function res = find_assign_QP(pt, mods)
        KK = size(mods,1);
        if KK == 1
            res = mods{1,1}(pt)';
        else
            l = zeros(KK,size(pt,2));
            res = zeros(size(pt,2),size(A,2));
            pred = cell(size(pt,2),1);

            for kk = 1:KK
                pred{kk} = mods{kk,1}(pt);
                l(kk,:) = sum((mods{kk,2}(pred{kk}') - pt).^2,1);
            end
            [~, mdl] = min(l,[],1);
            
            for kk = unique(mdl)
                res(mdl == kk,:) = pred{kk}(:,mdl==kk)';
            end
        end
    end

    function res = find_assign(pt, mods, assign_mod)
        KK = size(mods,1);
        res = zeros(size(pt,2),size(A,2));
        if KK == 1
            res = mods{1,1}(pt)';
        else
            %s_cent = forward_find_assign(cent, mods, cent);
            %[~, mdl] = min(pdist2(pt(1:6,:)', s_cent(:,1:6)),[],2);
            mdl=assign_mod.predict(pt');
            for kk = unique(mdl)'
                res(mdl == kk,:) = mods{kk,1}(pt(:,mdl == kk))';
            end
        end
    end

    function res = forward_find_assign(alphas, mods, cent)
        KK = size(mods,1);
        if KK == 1
            res = mods{1,2}(alphas)';
        else
            res = zeros(size(alphas, 1), size(P,2));
            [~, mdl] = min(pdist2(alphas, cent),[],2);
            
            for kk = unique(mdl)'
                res(mdl == kk,:) = mods{kk,2}(alphas(mdl == kk,:))';
            end
        end

    end

forward_fun = @(alpha) forward_find_assign(alpha, models, cent);


if use_regtree
    fun = @(pt) find_assign(pt, models, assign_mod);
else
    fun = @(pt) find_assign_QP(pt, models);
end
 
end