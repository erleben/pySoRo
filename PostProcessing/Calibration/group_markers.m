function [labeled_points, tform, success_flag, mse] =group_markers(close_points, points, max_distance)


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
    
    common_A =[common_A; points{1}(i(1),:)];
    common_B = [common_B; points{2}(j(1),:)];
    dist_mat(i(1),:) = inf;
    dist_mat(:,j(1)) = inf;
    added_A = [added_A; i(1)];
    added_B = [added_B; j(1)];
end
% dist - the minimum distance between a point in points{1} and points{2}
% perm - the ordering of points{1} to get the minimum distance

a = points{1}(setdiff(1:size(points{1},1),added_A),:); 
b = points{2}(setdiff(1:size(points{2},1),added_B),:);
c = close_points(setdiff(1:size(points{1},1),added_A),:); 
[R,T] = getTransformParam(common_A, common_B);

for p = 1:size(common_A,1)
    common_A(p,:)=(R*common_A(p,:)')'+T';
end

success_flag = abs(det(R)-1)<0.00001;

for p = 1:size(a,1)
    a(p,:)=(R*a(p,:)')'+T';
end 



common_mid = (common_A + common_B)/2;
mse = mean(sqrt(sum((common_A-common_B).^2,2)));
labeled_points.common = common_mid;

if success_flag 
labeled_points.exclusive = [a; b];
else
labeled_points.exclusive = [c; b];
end


tform.R = R;
tform.T = T;

success_flag = abs(det(R)-1)<0.00001;
end 