function cleaned = cleanAndInterp(points, num_to_keep, fill_missing)

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

%Fill in missing values

for pind = 1:num_markers
    last_good = num_alph;
    for alph = num_alph-1:-1:1
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


numE = zeros(1,num_to_keep);
for i = 1:num_alph
    numE(i) = sum(sum(E)<=i)/3;
end
min_thr = find(numE >= num_to_keep);
try
    min_thr = min_thr(1);
catch
    i
end
P(:,sum(E)>min_thr)=[];
E(:,sum(E)>min_thr)=[];

E = ~logical(E);
cleaned = cell(num_alph,1);
if ~fill_missing
    for i = 1:num_alph
        ps = [P(i,1:3:end)', P(i,2:3:end)', P(i,3:3:end)'];
        cleaned{i} = ps(E(i,1:3:end),:);
    end
else
    for i = 1:num_alph
        cleaned{i} = [P(i,1:3:end)', P(i,2:3:end)', P(i,3:3:end)'];
    end
    
end