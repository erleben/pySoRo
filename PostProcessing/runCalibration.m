% Finds the rigid transformation [R,T] that maps points in coordinate system
% A to coordinate system B. It is assumed that calibration data has been
% gathered for each of the cameras, (see
% pySoRo/DataAcqusition/pyCALIBRATE). The settings object contains paths to
% the data. See utils/makeSeettings.m


addpath('utilities/');

settings = makeSettings('16');

segment_balls = false;
remove_N_worst =0;

radius = 0.017;
use_radius = true;
show_spheres = true; 
with_color = true;
fit_circle = true;

% Get the centroids of the balls
[points_1, sphere_pcs_1] = getPoints(1, settings, radius, use_radius, fit_circle);
[points_2, sphere_pcs_2] = getPoints(2, settings, radius, use_radius, fit_circle);
 
[num_balls, ~] = size(points_1);

if segment_balls
    pc_balls_1 = sphere_pcs_1{1};
    pc_balls_2 = sphere_pcs_2{1};
    for num = 2:num_balls
        pc_balls_1 = pcmerge(pc_balls_1, sphere_pcs_1{num},0.0001);
        pc_balls_2 = pcmerge(pc_balls_2, sphere_pcs_2{num},0.0001);
    end
end 

% Find which centroids in points_1 corresponds to which
% centroids in points_2 by checking all permutations. Pick the
% permutaion with the smallest squared error.
% NB: Assumes that all balls have been detected
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
points_1 = points_1(perm(pind,:)',:);

% Get the transformation for the corresponding points
[R,T, mse, in] = getTransformRansac(points_1, points_2, num_balls-remove_N_worst);


% Read in the pointclouds
if segment_balls
    ref_PC = pc_balls_1;
    target_PC = pc_balls_2;
else
    ref_PC = pcread(settings.pc_name_calib{1});
    target_PC = pcread(settings.pc_name_calib{2});
end

% Apply transformation on ref_PC
ref_transformed = zeros(ref_PC.Count,3);
ref_points = ref_PC.Location;
for i = 1:ref_PC.Count
    ref_transformed(i,:)=(R*ref_points(i,:)')'+T';
end
ref_transformed_PC = pointCloud(ref_transformed, 'Color', ref_PC.Color);

if ~with_color
    ref_PC = pointCloud(ref_PC.Location);
    target_PC = pointCloud(target_PC.Location);
end


% Display the result
subplot(1,3,1);
pc_close = findNeighborsInRadius(ref_PC, median(ref_PC.Location), 0.5);
ref_PC= pointCloud(ref_PC.Location(pc_close,:),'Color', ref_PC.Color(pc_close,:));
pcshow(ref_PC);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
title('Point cloud A')

subplot(1,3,2);
pc_close = findNeighborsInRadius(target_PC, median(target_PC.Location), 0.5);
target_PC= pointCloud(target_PC.Location(pc_close,:),'Color', target_PC.Color(pc_close,:));
pcshow(target_PC);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
title('Point cloud B')

subplot(1,3,3);
pc_close = findNeighborsInRadius(ref_transformed_PC, median(ref_transformed_PC.Location), 0.5);
ref_transformed_PC= pointCloud(ref_transformed_PC.Location(pc_close,:),'Color', ref_transformed_PC.Color(pc_close,:));
pcshow(ref_transformed_PC);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
title('Point cloud B transformed')

% Merge the transformed pointcloud with the target-pointcloud
pcmerged=pcmerge(ref_transformed_PC, target_PC, 0.001);

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

if remove_N_worst
    disp('Removed ball number:')
    disp(setdiff(1:num_balls,in));
end


if show_spheres
    figure()
    for b =1:num_balls
        plot(sphereModel([((R*points_1(b,:)')'+T'),  radius]));
        hold on;
        plot(sphereModel([points_2(b,:),  radius]));
    end
    view([0 -90])
end


save(settings.tform_name, 'R', 'T');

%TODO:
%Consider to use ICP to fine tune R and T
%[tform, ICP_PC, dist] = pcregrigid(ref_transformed_PC, target_PC,'InlierRatio', 0.001);
%tf = affine3d(tform.T);
%pcshow(pcmerge(target_PC, pctransform(ref_transformed_PC,tf),0.001),'Markersize',100)
