
serial_1 = '618204002727';
serial_2 = '616205005055';

directory = 'data_5_balls/';

% Get the centroids of the balls
[points_1, sphere_pcs_1] = getPoints(serial_1, directory);
[points_2, sphere_pcs_2] = getPoints(serial_2, directory);

[num_balls, ~] = size(points_1);

% Find out which centroids in points_1 corresponds to which 
% centroids in points_2 by checking all permutations. Pick the 
% permutaion with the smallest squared error
perm = perms(1:num_balls);
se = zeros(length(perm),1);
for ind = 1:length(perm)
    points_1_perm = points_1(perm(ind,:)',:);
    [R,T] = getTransformParam(points_1_perm, points_2);
    if det(R) == -1
        se(ind) = inf;
    else
        for i = 1:num_balls
            se(ind) = se(ind) + sqrt(sum((points_2(i,:)-((R*points_1_perm(i,:)')'+T')).^2));
        end
    end
end

[mse, pind] = min(se);
mse=mse/num_balls;


% Get the transformation for the corresponding points
points_1 = points_1(perm(pind,:)',:);
[R,T] = getTransformParam(points_1, points_2);


% Read in the pointclouds
ref_PC = pcread(strcat(directory,serial_1,'fore.ply'));
target_PC = pcread(strcat(directory,serial_2,'fore.ply'));


% Apply transformation on ref_PC
ref_transformed = zeros(ref_PC.Count,3);
ref_points = ref_PC.Location;
for i = 1:ref_PC.Count
    ref_transformed(i,:)=(R*ref_points(i,:)')'+T';
end
ref_transformed_PC = pointCloud(ref_transformed, 'Color', ref_PC.Color);


% Display the result
subplot(1,3,1);
pcshow(ref_PC);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
title('Point cloud A')

subplot(1,3,2);
pcshow(target_PC);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
title('Point cloud B')

subplot(1,3,3);
pcshow(ref_transformed_PC); 
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
title('Point cloud B transformed')

% Merge the transformed pointcloud with the target-pointcloud
pcmerged=pcmerge(ref_transformed_PC,target_PC,0.001);

hold on;
figure;
pcshow(pcmerged);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
title('Point cloud A and B merged in same coordinate system')


disp('Rotation:');
disp(R);
disp('Translation');
disp(T);
disp('Determinant of R:')
disp(det(R));
disp('MSE of transformed centroids:');
disp(mse);