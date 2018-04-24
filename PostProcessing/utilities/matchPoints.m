function [P1_ord, P2_ord] = matchPoints(F1, F2, P1, P2, threshold)

if nargin < 5
    threshold = inf;
end

dists = pdist2(F1,F2);
dim = min(size(dists));

inds = [];

for num = 1:dim
    min_dist = min(dists(:));
    if min_dist > threshold
        break
    end
    [i,j]=find(dists==min_dist);
    inds(num, 1) = i(1);
    inds(num, 2) = j(1);
    
    dists(i(1),:) = inf;
    dists(:,j(1)) = inf;
    
end

P1_ord = zeros(size(P1,1),size(inds,1)*3);
for i = 1:length(inds)
    P1_ord(:,3*i-2:3*i) = P1(:,3*inds(i,1)-2:3*inds(i,1));
end

P2_ord = zeros(size(P2,1),size(inds,1)*3);
for i = 1:length(inds)
    P2_ord(:,3*i-2:3*i) = P2(:,3*inds(i,2)-2:3*inds(i,2));
end

end