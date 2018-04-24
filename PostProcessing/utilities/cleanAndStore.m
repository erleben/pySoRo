function cleanAndStore(points, name, seq)

% P: m*n matrix of m observations and n/3 variables. 
%    The format is [x, y, z, x, y, z, ...]
% E: Binary m*n matrix where E(i,j) if the j-th point in the i-th
%    observation was interpolated


% Put the points in P
[~, num_alph] = size(points);
[num_markers, ~] = size(points{num_alph}.all);
P = nan(num_alph, num_markers*3);
E = zeros(num_alph, 3*num_markers);

for alph = 1:num_alph
    S = points{alph}.all;
    for pind = 1:size(S,1)
        P(alph, pind*3-2:pind*3) = S(pind,:);
    end
    E(alph, 3*points{alph}.estimated'-2) = 1;
    E(alph, 3*points{alph}.estimated'-1) = 1;
    E(alph, 3*points{alph}.estimated') = 1;
    E(alph, isnan(P(alph,:))) = 1;
end
csvwrite('tabular_p2.csv','P');
%Fill in missing values
for pind = 1:num_markers 
    last_good = num_alph;
    for alph = seq(num_alph-1:-1:1)
        if isnan(P(alph, pind*3-2)) && (~isnan(P(last_good, pind*3-2)))

            p = P(last_good, pind*3-2:pind*3);
            tracked_in_lg = ~isnan(P(last_good,:));
            tracked_in_lg = tracked_in_lg(1:3:length(tracked_in_lg));
            tracked_in_this = ~isnan(P(alph,:));
            tracked_in_this = tracked_in_this(1:3:length(tracked_in_this));
            

            tracked_in_both = repelem(logical(tracked_in_this.*tracked_in_lg),3);
            tracked_in_both = logical(~(E(alph,:).*E(last_good,:)).*tracked_in_both);
            ps_lg = reshape(P(last_good,tracked_in_both), 3, sum(tracked_in_both)/3)';
            ps_this = reshape(P(alph,tracked_in_both), 3, sum(tracked_in_both)/3)';
            new_est = (p/ps_lg)*(ps_this);
            P(alph,pind*3-2:pind*3) = new_est;
            E(alph, pind*3-2:pind*3) = 1;
        end
        
        last_good = alph;
        
    end
end

% Decide what criteria for keeping estimated data should be. Delete bad
% points
sz = 2;
num_markers = 19;
numE = zeros(1,num_markers);
for i = 1:num_alph/2
    numE(i) = sum(sum(E)<=i)/3;
end
min_thr = find(numE >= num_markers);
min_thr = min_thr(1);
P(:,sum(E)>min_thr)=[];
figure;
num_good = sum(sum(E)<=min_thr)/3;
for i = 1:num_good
    scatter3(P(:,3*i-2),P(:,3*i-1),P(:,3*i), sz);
    hold on;
end
%pcshow(pcread('../../data/output_exp1/1_616205005055.ply'),'MarkerSize',10)

csvwrite(strcat('data/points_',name,'.csv'),P)

[~, ~, ~, ~, ~, P] = findModes(P, 3);
figure;

for i = 1:num_good 
    scatter3(P(:,3*i-2),P(:,3*i-1),P(:,3*i),sz);
    hold on;
end
%pcshow(pcread('../../data/output_exp1/1_616205005055.ply'),'MarkerSize',10)

csvwrite(strcat('data/points_pca_',name,'.csv'),P)
end