%% For loading post processed point clouds and plotting these.
folder = strcat('/Users/NewUser/Documents/DataAcquisitionMathias/experiment2/');
settings = makeSettings('4', '1', ["821312062271", "732612060774"], '../../calibration2/', '../../experiment2/');

robot_pointclouds = load(strcat(settings.path_to_calib, 'unordered_points_g2.mat'));
%Visualize robot surface with depth and with mask.
showRobotSurface(robot_pointclouds.points{117});


%% Loading a pre processing point cloud and plotting.
folder = strcat('/Users/NewUser/Documents/DataAcquisitionMathias/experiment2/');
settings = makeSettings('4');

alphamap = csvread(strcat(settings.path_to_pcs, 'alphamap.csv'));

pcloud = pcread(strcat(folder, int2str(1),'_',settings.serial(1),'.ply'));
pc_close = findNeighborsInRadius(pcloud, median(pcloud.Location), 0.5);
pcloud1 = pointCloud(pcloud.Location(pc_close,:), 'Color', pcloud.Color(pc_close,:));
pc1 = pcdenoise(pcloud1);
normals = pcnormals(pc1);

x = pc1.Location(1:10:end,1);
y = pc1.Location(1:10:end,2);
z = pc1.Location(1:10:end,3);
u = -normals(1:10:end,1);
v = -normals(1:10:end,2);
w = -normals(1:10:end,3);

pcshow(pc1);
hold on;
quiver3(x,y,z,u,v,w);




%centered = pc1.Location-mean(pc1.Location);
%mean(centered)
%showRobotSurface(pc1);
