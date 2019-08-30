% Finds the rigid transformation [R,T] that maps points in coordinate system
% A to coordinate system B. It is assumed that calibration data has been
% gathered for each of the cameras, (see
% pySoRo/DataAcqusition/pyCALIBRATE). The settings object contains paths to
% the data. See utils/makeSeettings.m


addpath('utilities/');

settings = makeSettings('5', '1', ["821312062271", "732612060774"], '../../calibration5/','../../experiment5/');

segment_balls = false;
remove_N_worst = 0;


radius = 0.001;
% added scale factor from camera space to real_world measurements.
real_radius_ball = 32/2;
S = real_radius_ball/radius;
use_radius = true;
show_spheres = true;
with_color = true;
fit_circle = true;

% Get the centroids of the balls
[points_1, sphere_pcs_1] = getPoints(1, settings, radius, use_radius, fit_circle);
[points_2, sphere_pcs_2] = getPoints(2, settings, radius, use_radius, fit_circle);
 
[num_balls, ~] = size(points_1);


%
pc = sphere_pcs_1{1}.Location;
pc1 = pc - mean(pc);
radius1 = 0.0;
for i = 1:length(pc1)
    radius1 = radius1 + pdist([0,0,0; pc1(i,:)], 'euclidean');
end
radius = radius1/length(pc1);
%max(pc(:,1)) - min(pc(:,1));
S = real_radius_ball/(radius);


%
% accum_radius = 0.0;
% 
% pc1_ball = sphere_pcs_1{1}.Location;
% pc1_point = points_1(1,:);
% 
% for i = 2:num_balls
%     X = points_1(i,1);
%     max(X)-min(X);
%     Ydist = abs(pc1_point(2) - points_1(i,2));
%     Zdist = abs(pc1_point(3) - points_1(i,3));
%     pdist([pc1_point(2:3); points_1(i,2:3)], 'euclidean')
%     
% end
%mean(points_1,1)
%mean(points_2,1)


% real_world_diameter = 3.2*10;
% X = sphere_pcs_1{1}.Location(:,1);
% X1 = sphere_pcs_2{1}.Location(:,1);
% 
% scaling1 = real_world_diameter/abs(max(X1) - min(X1));
% scaling2 = (real_world_diameter/2)/radius;
% 
% ref_PC = pcread(settings.pc_name_calib{1});
% pc_close = findNeighborsInRadius(ref_PC, median(ref_PC.Location), 0.5);
% ref_PC1= pointCloud(ref_PC.Location(pc_close,:).*scaling2,'Color', ref_PC.Color(pc_close,:));
% % new_locations = ref_PC1.Location*scaling;
% % pc1 = pointCloud(new_locations, 'Color', ref_PC.Color);
%figure();
%pcshow(ref_PC1);


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
%subplot(1,3,1);
figure();
pc_close = findNeighborsInRadius(ref_PC, median(ref_PC.Location), 0.5);
ref_PC= pointCloud(ref_PC.Location(pc_close,:).*S,'Color', ref_PC.Color(pc_close,:));
pcshow(ref_PC);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
%title('Point cloud A')

%subplot(1,3,2);
figure();
pc_close = findNeighborsInRadius(target_PC, median(target_PC.Location), 0.5);
target_PC = pointCloud(target_PC.Location(pc_close,:).*S,'Color', target_PC.Color(pc_close,:));
pcshow(target_PC);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
%title('Point cloud B')

%subplot(1,3,3);
figure();
pc_close = findNeighborsInRadius(ref_transformed_PC, median(ref_transformed_PC.Location), 0.5);
ref_transformed_PC= pointCloud(ref_transformed_PC.Location(pc_close,:).*S,'Color', ref_transformed_PC.Color(pc_close,:));
pcshow(ref_transformed_PC);
view([0 -90])
xlabel('x');
ylabel('y');
zlabel('z');
%title('Point cloud B transformed')

% Merge the transformed pointcloud with the target-pointcloud
pcmerged=pcmerge(ref_transformed_PC, target_PC, 0.001);
%
hold on;
figure;
pcshow(pcmerged);
view([0 -90])
xlabel('x'); 
ylabel('y');
zlabel('z');
%title('Point cloud A and B merged in same coordinate system')


disp('Rotation:');
disp(R);
disp('Translation');
disp(T);
disp('Determinant of R:')
disp(det(R));
disp('MSE of transformed centroids:');
disp(mse);
%
if remove_N_worst
    disp('Removed ball number:')
    disp(setdiff(1:num_balls,in));
end
hold off;


if show_spheres
    hold on;
    figure();
    for b =1:num_balls
        plot(sphereModel([((R*points_1(b,:)')'+T'),  radius+0.01]));
        hold on;
        plot(sphereModel([points_2(b,:),  radius+0.01]));
    end
    view([0 -90])
end
xlabel('x'); 
ylabel('y');
zlabel('z');
grid on;
hold off;

if show_spheres
    hold on;
    figure();
    for b =1:num_balls
        hold on;
        plot(sphereModel([points_1(b,:),  radius]));
    end
    view([0 -90])
end
xlabel('x'); 
ylabel('y');
zlabel('z');
grid on;
hold off;
if show_spheres
    hold on;
    figure();
    for b =1:num_balls
        hold on;
        plot(sphereModel([points_2(b,:),  radius]));
    end
    view([0 -90])
end
xlabel('x'); 
ylabel('y');
zlabel('z');
grid on;
hold off;
%
if show_spheres
    hold on;
    figure();
    pcshow(pcmerged);
    for b =1:num_balls
        hold on;
        plot(sphereModel([((R*points_1(b,:)')'+T').*S,  real_radius_ball*1.5]));
        hold on;
        plot(sphereModel([points_2(b,:).*S,  real_radius_ball*1.5]));
    end
    view([0 -90])
end
grid on;
xlabel('x'); 
ylabel('y');
zlabel('z');
hold off;


save(settings.tform_name, 'R', 'T', 'S');

%TODO:
%Consider to use ICP to fine tune R and T
%[tform, ICP_PC, dist] = pcregrigid(ref_transformed_PC, target_PC,'InlierRatio', 0.001);
%tf = affine3d(tform.T);
%pcshow(pcmerge(target_PC, pctransform(ref_transformed_PC,tf),0.001),'Markersize',100)