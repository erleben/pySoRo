

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

for i = 1:(length(alphamap))
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
    
    %points{i} = getMarkerCentroids(settings);
    [pc1, pc2, mergedpc] = getSurfacePointClouds(settings, tform, [100; 100; 100], 0.1);
    pcloud1{i} = pc1;
    pcloud2{i} = pc2;
    pc_merged{i} = mergedpc;
    
    strcat("processed ", int2str(i), "/", int2str(length(alphamap)))
    %points{i};
    %Visualize robot surface with depth and with mask.
    %showRobotSurface(mergedpc);
end

%% Store matlab files
save(strcat(settings.path_to_calib, 'unordered_points_pcloud1.mat'),'pcloud1');
save(strcat(settings.path_to_calib, 'unordered_points_pcloud2.mat'),'pcloud2');
save(strcat(settings.path_to_calib, 'unordered_points_pcmerged.mat'),'pc_merged');
%% Store to Simulation pcloud data structure.
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_merged.obj'), pc_merged);
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_1.obj'), pcloud1);
writeToObjFile(strcat(settings.path_to_calib, 'vega_point_clouds_2.obj'), pcloud2);