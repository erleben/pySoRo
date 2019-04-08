

%%
% NB: You have to run runCalibration for the current camera setting before
% running this script.
% This script segments the markers on the soft robot and find its xyz
% corrdinates (centers). The segmented data is stored in a MxN mat file
% where M is the number of iterations and N = number of markers *
% dimension of points. 
ordered = {};

addpath('utilities/');
addpath('visualization/');

folder = strcat('/Users/NewUser/Documents/DataAcquisitionMathias/experiment3/');
settings = makeSettings('4');


%folder = '../data/experiment_3/output_exp1/';
%settings = makeSettings('13');
alphamap = csvread(strcat(settings.path_to_pcs, 'alphamap.csv'));
tform = load(settings.tform_name);
%for i = 100:100%length(alphamap)
for i = 1:1%(length(alphamap))
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
    
    %points{i} = getMarkerCentroids(settings);
    [pc1, pc2, mergedpc] = getSurfacePointClouds(settings, tform, [100; 100; 100], 0.1);
    points{i*3-2} = pc1;
    points{i*3-1} = pc2;
    points{i*3} = mergedpc;
    
    strcat("processed ", int2str(i), "/", int2str(length(alphamap)))
    %points{i};
    %Visualize robot surface with depth and with mask.
    showRobotSurface(mergedpc);
    showRobotSurface(pc1);
    showRobotSurface(pc2);
    %hold off;

end
%%
tform = load(settings.tform_name);
%%
save(strcat(settings.path_to_calib, 'unordered_points_g2.mat'),'points');
%%
writeToObjFile(strcat(settings.path_to_calib, 'unordered_points_g2.obj'), points);
%%
channel1 = (find(pc1.Color(:,1) > 245));
pc2 = pointCloud(pc1.Location(channel1,:), 'Color', pc1.Color(channel1,:));

channel2 = (find(pc2.Color(:,2) > 245));
pc3 = pointCloud(pc2.Location(channel2,:), 'Color', pc2.Color(channel2,:));

channel3 = (find(pc3.Color(:,2) > 245));
pc4 = pointCloud(pc3.Location(channel3,:), 'Color', pc3.Color(channel3,:));

pc_close = findNeighborsInRadius(pc4, mean(pc4.Location), 0.3);
pc5 = pointCloud(pc4.Location(pc_close,:),'Color', pc4.Color(pc_close,:));

%%
a = im2double(pc5.Color);
b = rgb2gray(a);

grayscale_mask = find(b(:,1) > 0.9);

pc6 = pointCloud(pc5.Location(grayscale_mask,:),'Color', pc5.Color(grayscale_mask,:)./10);


%%


%%
hold on;
%subplot(1,2,1);
%figure();
%pcshow(pc.Location(:));
%pcshow(pc5);
%pcshow(pc3);
%pcshow([pc4.Location(:,1), pc4.Location(:,2), pc4.Location(:,3)]);
pcshow([pc5.Location(:,1), pc5.Location(:,2), pc5.Location(:,3)]);
%pcshow([pc6.Location(:,1), pc6.Location(:,2), pc6.Location(:,3)]);
%pcshow(pc6);
%hold on;
%subplot(1,2,1);
%pcshow([pc5.Location(:,1), pc5.Location(:,2), pc5.Location(:,3)]);
hold off;

%%
D = imread(strcat(folder, '1_821312062271color.tif'));
imshow(D);

