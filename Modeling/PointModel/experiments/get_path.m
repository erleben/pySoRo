function path = get_path(a_0, s_goal, obstacle_c, obstacle_r, p_model, rf_model, A)

num_samples = 1000;     % Resolution
connectivity = 30;      % Allows shorcuts
c = 15000;              % Penalty 

a_goal = p_model(s_goal');

% SAMPLE
sample=round(rand(num_samples, 2).*(A.max-A.min)+A.min);
sample = [a_0; a_goal; sample];

SSR = rf_model(sample);
num_p = size(SSR,2)/3;

% FIND COLLISION SPACE
no_collision = true(num_samples+2,1);

for i = 1:num_p
    no_collision =no_collision.*logical(sqrt(sum((SSR(:,3*i-2:3*i)-obstacle_c).^2,2))>obstacle_r);
end
    
no_collision(1:2) = true;
no_collision = logical(no_collision);

% RESAMPLE
COL = sample(~no_collision,:);
pun=c./min(pdist2(sample,COL),[],2);

to_remove = true(length(no_collision),1);
pun = 1./pun;
pun = pun/max(pun);
pun = pun*0.7;
pun = pun +0.3;
for i  =1:length(to_remove)
    to_remove(i) = binornd(1,pun(i));
end
to_keep = logical(~logical(to_remove).*logical(no_collision));
to_keep(1:2)=true;
sample = sample(to_keep,:);

if isempty(COL)
    pun = zeros(size(sample,1),1);
else
    pun=c./min(pdist2(sample,COL),[],2);
end

% Create a weighted graph where each node is a configration. Connected to
% the closest configurations. The weight is the distance between them.
dist_mat = pdist2(sample,sample);

[~, di] = mink(dist_mat, connectivity);
for i = 1:size(dist_mat,1)
    dist_mat(i, di(:,i)) = -dist_mat(i,di(:,i));
end
dist_mat(dist_mat>0) = 0;
dist_mat = -dist_mat;

G=digraph(dist_mat);

W = G.Edges.Weight;
Nodes = G.Edges.EndNodes;

for n = 1:G.numnodes
    W(Nodes(:,2)==n) = W(Nodes(:,2)==n) + pun(n);
end
G.Edges.Weight = W;

path_idx = shortestpath(G,1,2);

path = sample(path_idx,:);

end