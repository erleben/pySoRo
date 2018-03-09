function getMarkerCentroids(path_to_pcs, serial_1, serial_2, fore_1, fore_2, postfix, isObj_1, isObj_2, tex_1, tex_2)

marker_pcs = {};
%Get at list of pointclouds of markers in each cloud
PC_from = pcread(strcat(path_to_pcs, serial_1, postfix, '.ply'));
is_marker = detectMarkers(imread(fore_1), isObj_1{1});
marker_pcs{1} = getObjPointclouds(is_marker', PC_from, tex_1);

PC_to = pcread(strcat(path_to_pcs, serial_2, postfix, '.ply'));
is_marker = detectMarkers(imread(fore_2), isObj_2{1});
marker_pcs{2} = getObjPointclouds(is_marker', PC_to, tex_2);

%Find their centroids
points = {};
num_markers = length(marker_pcs{1});
points{1} = zeros(num_markers,3);
points{2} = zeros(num_markers,3);

for i = 1:2
    for j = 1:num_markers
        points{i}(j,:) = mean(marker_pcs{i}{j}.Location);
    end
end

% Find which centroids in points_1 corresponds to which 
% centroids in points_2 by checking all permutations. Pick the 
% permutaion with the smallest squared error
perm = perms(1:num_markers);
se = zeros(length(perm),1);
for ind = 1:length(perm)
    points_1_perm = points{1}(perm(ind,:)',:);
    [R,T] = getTransformParam(points_1_perm, points{2});
    if det(R) == -1
        se(ind) = inf;
    else
        for i = 1:num_markers
            se(ind) = se(ind) + sqrt(sum((points{2}(i,:)-((R*points_1_perm(i,:)')'+T')).^2));
        end
    end
end

[mse, pind] = min(se);
mse=mse/num_markers;
points{1} = points{1}(perm(pind,:)',:);

%Get the transformation to align the two sets
[R,T] = getTransformParam(points{1},points{2});

% Merge the pointclouds
pc_balls_1 = marker_pcs{1}{1};
pc_balls_2 = marker_pcs{2}{1};
for num = 2:num_markers
    pc_balls_1 = pcmerge(pc_balls_1, marker_pcs{1}{num},0.0001);
    pc_balls_2 = pcmerge(pc_balls_2, marker_pcs{2}{num},0.0001);
end

%Visualize the result of applying the transformation on the two pointclouds
P_from = PC_from;
P_to = PC_to;
ref_transformed = zeros(P_from.Count,3);
ref_points = P_from.Location;
for i = 1:P_from.Count
    ref_transformed(i,:)=(R*ref_points(i,:)')'+T';
end
ref_transformed_PC = pointCloud(ref_transformed, 'Color', P_from.Color);

pc_balls_2 = pointCloud(P_to.Location,'Color', fliplr(P_to.Color));
PP=pcmerge(ref_transformed_PC,pc_balls_2, 0.0001);
pcshow(PP,'MarkerSize',5);

end