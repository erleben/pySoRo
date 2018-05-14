function labeled_points =group_markers(close_points, points, max_distance)


dist_mat = pdist2(close_points,points{2});

common_A = [];
added_A = [];
common_B = [];
added_B = [];
while true
    [i,j]=find(dist_mat==min(dist_mat(:)));
    
    if (dist_mat(i(1),j(1)) > max_distance) || isnan(dist_mat(i(1),j(1)))
        break
    end
    
    common_A =[common_A; close_points(i(1),:)];
    common_B = [common_B; points{2}(j(1),:)];
    dist_mat(i(1),:) = inf;
    dist_mat(:,j(1)) = inf;
    added_A = [added_A; i(1)];
    added_B = [added_B; j(1)];
end
% dist - the minimum distance between a point in points{1} and points{2}
% perm - the ordering of points{1} to get the minimum distance

a = close_points(setdiff(1:size(close_points,1), added_A),:); 
b = points{2}(setdiff(1:size(points{2},1), added_B),:);

common_mid = (common_A + common_B)/2;
labeled_points.common = common_mid;

labeled_points.exclusive = [a; b];

labeled_points.all = [labeled_points.common; labeled_points.exclusive];

end 