

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

showRobot = false;
for i = 1:1%20%(length(alphamap))
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
    
    %points{i} = getMarkerCentroids(settings);
    c = 10;
    [pc1, pc2, mergedpc] = getSurfacePointClouds(settings, tform, [c;c;c], 0.15, 0.007);
    pcloud1{i} = pc1;
    pcloud2{i} = pc2;
    pc_merged{i} = mergedpc;
    
    strcat("processed ", int2str(i), "/", int2str(length(alphamap)))
    %points{i};
    
%     p = double(pc1.Location);
%     [t]=MyCrustOpen(p);
%     figure(10);
%     set(gcf,'position',[0,0,1280,800]);
%     subplot(1,2,1)
%     hold on
%     axis equal
%     title('Points Cloud','fontsize',14)
%     plot3(p(:,1),p(:,2),p(:,3),'g.')
%     axis vis3d
%     view(3)
%     % plot the output triangulation
%     figure(10)
%     subplot(1,2,2)
%     hold on
%     title('Output Triangulation','fontsize',14)
%     axis equal
%     trisurf(t,p(:,1),p(:,2),p(:,3),'facecolor','c','edgecolor','b')%plot della superficie
%     axis vis3d
%     view(3)
    %Visualize robot surface with depth and with mask.
    if (showRobot)
        showRobotSurface(mergedpc, 'Merged robot point cloud', 1,2);
        showRobotSurface(pc1, strcat(settings.serial(1), ' robot point cloud'), 3,4);
        showRobotSurface(pc2, strcat(settings.serial(2), ' robot point cloud'), 5,6);
    end
end

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
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_merged.obj'), pc_merged);
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_1.obj'), pcloud1);
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_2.obj'), pcloud2);