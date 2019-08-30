

%%
% NB: You have to run runCalibration for the current camera setting before
% running this script.
% This script segments the markers on the soft robot and find its xyz
% corrdinates (centers). The segmented data is stored in a MxN mat file
% where M is the number of iterations and N = number of markers *
% dimension of points. 
clc
clear
close all
ordered = {};

addpath('utilities/');
addpath('visualization/');

folder = strcat('/Users/NewUser/Documents/DataAcquisitionMathias/experiment3/');
settings = makeSettings('4','1',["821312062271", "732612060774"],'../../calibration3/','../../experiment3/');

alphamap = csvread(strcat(settings.path_to_pcs, 'alphamap.csv'));
tform = load(settings.tform_name);
showReconstruction = true;
showRobot = false;
T = [0,0,0];
for i = 1:1
%for i = 1:2
%for i = 1:20
%for i = 1:(length(alphamap))
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
    
    %points{i} = getMarkerCentroids(settings);
    c = 10;
    % downsampled
    [pc1, pc2, mergedpc] = getSurfacePointClouds(settings, tform, [c;c;c], 0.15, 0.0015, [0,0,0]);
    % full pcloud
    %[pc1, pc2, mergedpc] = getSurfacePointClouds(settings, tform, [c;c;c], 0.15, 0.0005);
    if (i == 1) 
        [tform1, pc2] = getRobotTransform(pc2, -10);
        pc1 = applyRobotTransform(pc1, tform1);
        mergedpc = applyRobotTransform(mergedpc, tform1);
    else
        pc1 = applyRobotTransform(pc1, tform1);
        pc2 = applyRobotTransform(pc2, tform1);
        mergedpc = applyRobotTransform(mergedpc, tform1);
    end
    %pc1 = translateRobot(pc1, tform, T);
    %pc2 = translateRobot(pc2, tform, T);
    %mergedpc = translateRobot(mergedpc, tform, T);
    pcloud1{i} = pc1;
    pcloud2{i} = pc2;
    pc_merged{i} = mergedpc;
    
    strcat("processed ", int2str(i), "/", int2str(length(alphamap)))
    %points{i};
    
    %Visualize robot surface with depth and with mask.
    if (showRobot)
        showRobotSurface(mergedpc, 'Merged robot point cloud', 1,2);
        showRobotSurface(pc1, strcat(settings.serial(1), ' robot point cloud'), 3,4);
        showRobotSurface(pc2, strcat(settings.serial(2), ' robot point cloud'), 5,6);
    end
end

%%
 showRobotSurface(mergedpc, 'Merged robot point cloud', 1,2);
 showRobotSurface(pc1, strcat(settings.serial(1), ' robot point cloud'), 3,4);
 showRobotSurface(pc2, strcat(settings.serial(2), ' robot point cloud'), 5,6);
 %%
 
 pcshow(pc2);
%%
location = pc2.Location;
new = location(:,1) < -10;
pc = pointCloud(location(new,:), 'Color', pc2.Color(new,:));
pc_close = findNeighborsInRadius(pc, mean(pc.Location), 5.0);
T = mean(pc.Location);
ptCloud = pc2;
normals = pcnormals(ptCloud);

% pcshow(pc2);
% [model, pcloud_out, out] = pcloudROIPlane(pc2, 100);
% hold on;
% ptCloud = pointCloud(ptCloud.Location.*model.Normal, 'Color', ptCloud.Color);
% pcshow(ptCloud);
location = pc2.Location;
Py = polyfit(location(:,1), location(:,2), 1);
Pz = polyfit(location(:,1), location(:,3), 1);
x = linspace(-1,1,1);
yfit = Py(1)*location(:,1) + Py(2);
zfit = Pz(1)*location(:,1) + Pz(2);
figure();
hold on;
xlabel('x(mm)');
ylabel('y(mm)');
zlabel('z(mm)');
hold on;
%plot3(location(:,1), yfit, zfit, '-');
xfit = linspace(-20,100);
yfit = Py(1)*xfit + Py(2);
zfit = Pz(1)*xfit + Pz(2);
%plot3(xfit, yfit, zfit, '-');
hold on;
pcshow(pc2);
hold on;
% pc = select(pc, pc_close);
% pcshow([pc.Location(:,1), pc.Location(:,2), pc.Location(:,3)]);
pc = pointCloud(pc.Location(pc_close,:), 'Color', pc.Color(pc_close,:)*0);
pcshow(pc);
hold on;
mean(pc.Location);
sorted = sort(pc.Location, 1);
x1 = [[max(sorted(:,1))]];
% yfit = Py(1)*x1 + Py(2);
% zfit = Pz(1)*x1 + Pz(2);
% plot3(location(:,1), yfit, zfit, 'o');
% hold on;
%pc = pointCloud(pc2.Location, 'Color', pc2.Color);
%pc_close = findNeighborsInRadius(pc, [x,yfit,zfit], 5.0);
[model, pcloud_out, out] = pcloudROIPlane(pc2new, 1);

x1 = xfit(1);
x2 = xfit(length(xfit));

rstart = [x1 x1*Py(1) x1*Pz(1)];
rend = [x2 x2*Py(1) x2*Pz(1)];
%r1 = rend-rstart;
%r1 = r1/norm(r1);
r1 = model.Normal;
% orthogonal vectors to r1
R = null(r1(:).');
R = [r1', R];


x = linspace(0,20);
l1 = line(x*R(1,1),x*R(1,2)+Py(2), x*R(1,3)+Pz(2));
l1.Color = 'r';
hold on;
y = linspace(0,20);
l2 = line(y*R(1,2), y*R(2,2)+Py(2), y*R(3,2)+Pz(2));
l2.Color = 'g';
hold on;
z = linspace(0, 20);
l3 = line(z*R(1,3),z*R(2,3)+Py(2), z*R(3,3)+Pz(2));
l3.Color = 'b';
%axis([-100 100 -100 100 -100 100]);
% 
% x = linspace(-20,100);
% l1 = line(x,x*R(2,1)+Py(2), x*R(3,1)+Pz(2));
% l1.Color = 'r';
% hold on;
% y = linspace(-20,20);
% l2 = line(y*R(1,2),y+Py(2), y*R(3,2)+Pz(2));
% l2.Color = 'g';
% hold on;
% z = linspace(-20, 20);
% l3 = line(z*R(1,3),z*R(2,3)+Py(2), z+Pz(2));
% l3.Color = 'b';
% a1 = [a(1) a(3) a(2)];
% a = atan2(norm(cross(model.Normal,a1)), ...
%                 dot(model.Normal,a1));
% 

%%
[tform1, ptCloud] = getRobotTransform(pc2, -10);

%%
% Identify base of robot, the left most pixels qualifying as the robot
% along the x axis.
location = pc2.Location;
new = location(:,1) < -10;
pc = pointCloud(location(new,:), 'Color', pc2.Color(new,:));
pc_close = findNeighborsInRadius(pc, mean(pc.Location), 5.0);
pc = pointCloud(pc.Location(pc_close,:), 'Color', pc.Color(pc_close,:)*0);
% translate robot to origin of the coordinate system.
translation = mean(pc.Location);
tform.T = translation;
pc2new = pointCloud(pc2.Location-translation, 'Color', pc2.Color);
% Identify plane orientation of robot surface.
[model, pcloud_out, out] = pcloudROIPlane(pc2new, 0.1);
r1 = model.Normal;
% orthogonal vectors to r1
R = null(r1(:).');
R = [r1', R];
l = pc2new.Location;
a = [];
a1 = [];
% Identify what we deem to be the exterior side of the surface point
% cloud.
for i = 1:length(l)
    p1 = l(i,:);
    angle = atan2(norm(cross(p1, r1)), dot(p1, r1));
    if radtodeg(angle) < 90
        a = [a; i];
    else
        a1 = [a1; i];
    end
end
% Identify plane top.
if length(a) > length(a1)
    loc = l(a,:);
    col = pc2new.Color(a,:);
    loc1 = l(a1,:);
    col1 = pc2new.Color(a1,:)*0;
else
    loc = l(a1,:);
    col = pc2new.Color(a1,:);
    R(:,1) = R(:,1)*-1;
    model = planeModel([model.Normal*-1, model.Parameters(4)]);
    loc1 = l(a,:);
    col1 = pc2new.Color(a,:)*0;
end
% Produce points that lay above and under plane.
pc2new3 = pointCloud(loc, 'Color', col);
pc2new31 = pointCloud(loc1, 'Color', col1);

% Plotting
hold on;
xlabel('x(mm)');
ylabel('y(mm)');
zlabel('z(mm)');
hold on;
pcshow(pc2new31);
pcshow(pc2new3);
grid on;
view([0 0]);
hold on;
x = linspace(0,20);
l1 = line(x*R(1,1),x*R(2,1), x*R(3,1));
l1.Color = 'g';
l1.LineWidth = 2;
hold on;
y = linspace(0,20);
l2 = line(y*R(1,2), y*R(2,2), y*R(3,2));
l2.Color = 'b';
l2.LineWidth = 2;
hold on;
l1 = line(x*0,x*1, x*0);
l1.Color = 'r';
l1.LineWidth = 2;
hold on;
z = linspace(0, 20);
l3 = line(z*R(1,3),z*R(2,3), z*R(3,3));
l3.Color = 'c';
l3.LineWidth = 2;
%%
% Rotating plane orientation to 0 1 0.
r = vrrotvec2mat(vrrotvec(model.Normal,[0 1 0]));
pc2new1 = pointCloud((r*pc2new.Location')', 'Color', pc2new.Color);

location = pc2new1.Location;
Pz = polyfit(location(:,1), location(:,3), 1);

%plotting
figure();
x = linspace(0,20);
l1 = line(x*0,x*1, x*0);
l1.Color = 'g';
l1.LineWidth = 2;
hold on;
x = linspace(0,130);
l1 = line(x*1,x*0, x*Pz(1));
l1.Color = 'r';
l1.LineWidth = 2;
hold on;
l1 = line(x*1,x*0, x*0);
l1.Color = 'c';
l1.LineWidth = 2;
hold on;
pcshow(pc2new1);
xlabel('x(mm)');
ylabel('y(mm)');
zlabel('z(mm)');
view([0 0]);
grid on;
%%
location = pc2new1.Location;
Pz = polyfit(location(:,1), location(:,3), 1);

v1 = [1 0 Pz(1)];
v1 = v1/norm(v1);
r1 = vrrotvec2mat(vrrotvec(v1,[1 0 0]));
pc2new2 = pointCloud((r1*pc2new1.Location')', 'Color', pc2new1.Color);

location = pc2new2.Location;
Pz = polyfit(location(:,1), location(:,3), 1);

%plotting
figure();
x = linspace(0,20);
l1 = line(x*0,x*1, x*0);
l1.Color = 'g';
l1.LineWidth = 2;
hold on;
x = linspace(0,130);
l1 = line(x*1,x*0, x*Pz(1));
l1.Color = 'r';
l1.LineWidth = 2;
hold on;
l1 = line(x*1,x*0, x*0);
l1.Color = 'c';
l1.LineWidth = 2;
hold on;
pcshow(pc2new2);
xlabel('x(mm)');
ylabel('y(mm)');
zlabel('z(mm)');
view([0 90]);
grid on;

%%
locs = (location-T)
figure();
pcshow([locs(:,1), locs(:,2), locs(:,3)]);

%%
figure();
hold on;
pcshow(pc2);
hold on;
quiver3(x,y,z,u,v,w);
xlabel('x');
ylabel('y');
zlabel('z');


%% Visualize point cloud triangulation

visualizePointCloud(pc1,1);
visualizePointCloud(pc2,2);
visualizePointCloud(mergedpc,3);

%%
first = pcread(settings.pc_name_recon{1});
second = pcread(settings.pc_name_recon{2});

pc_close = findNeighborsInRadius(first, median(first.Location), 0.65);
first = select(first, pc_close);
pc_close = findNeighborsInRadius(first, median(first.Location), 0.65);
first = select(first, pc_close);
showRobotSurface(first,1,1,2);

pc_close = findNeighborsInRadius(second, median(second.Location), 0.65);
second = select(second, pc_close);
pc_close = findNeighborsInRadius(second, median(second.Location), 0.65);
second = select(second, pc_close);


showRobotSurface(second,1,3,4);



%%
showRobotSurface(mergedpc, 'Merged robot point cloud', 1,2);
showRobotSurface(pc1, strcat(settings.serial(1), ' robot point cloud'), 3,4);
showRobotSurface(pc2, strcat(settings.serial(2), ' robot point cloud'), 5,6);


%% Store matlab files
save(strcat(settings.path_to_calib, 'unordered_points_pcloud1.mat'),'pcloud1');
save(strcat(settings.path_to_calib, 'unordered_points_pcloud2.mat'),'pcloud2');
save(strcat(settings.path_to_calib, 'unordered_points_pcmerged.mat'),'pc_merged');
%% Store to Simulation pcloud data structure.
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_merged1.obj'), pc_merged);
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_11.obj'), pcloud1);
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_21.obj'), pcloud2);