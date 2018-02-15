
serial_1 = '618204002727';
serial_2 = '616205005055';
directory = 'data/';

% Get the centroids of the balls
points_1 = getPoints(serial_1, directory);
points_2 = getPoints(serial_2, directory);

% Need to label the points. 
% Todo: Automate by colorcoding
points_2 = circshift(points_2,1);
p = points_2;
p(1,:) = points_2(2,:);
p(2,:) = points_2(1,:);
p(3,:) = points_2(4,:);
p(4,:) = points_2(3,:);
points_2=p;
[R,T] = getTransformParam(points_1, points_2);

% Compute the mean error of the transformed centroids
mse = 0;
for i = 1:length(points_1)
    mse = mse + sqrt(sum((points_2(i,:)-((R*points_1(i,:)')'+T')).^2));
end
points_1_trans = points_1;
for i = 1:length(points_1)
    points_1_trans(i,:)=(R*points_1(i,:)')'+T';
end
mse=mse/length(points_1);


% Read in the pointclouds
ref_PC = pcread(strcat(directory,serial_1,'fore.ply'));
target_PC = pcread(strcat(directory,serial_2,'fore.ply'));

% scatter3(points_1_trans(:,1),points_1_trans(:,2),points_1_trans(:,3),'b','f')
% hold on;
% scatter3(points_2(:,1),points_2(:,2),points_2(:,3),'r','f');

% Apply transformation on ref_PC
ref_transformed = zeros(ref_PC.Count,3);
ref_points = ref_PC.Location;
for i = 1:ref_PC.Count
    ref_transformed(i,:)=(R*ref_points(i,:)')'+T';
end


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
ref_transformed_PC = pointCloud(ref_transformed, 'Color', ref_PC.Color);
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