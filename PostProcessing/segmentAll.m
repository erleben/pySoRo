% NB: You have to run runCalibration for the current camera setting before
% running this script.
% This script segments the markers on the soft robot and find its xyz
% corrdinates (centers). The segmented data is stored in a MxN mat file
% where M is the number of iterations and N = number of markers *
% dimension of points. 
ordered = {};



folder = strcat('/Volumes/TOSHIBA/experiment5/');
settings = makeSettings('16');

%folder = '../data/experiment_3/output_exp1/';
%settings = makeSettings('13');
num_alphas = 1189;


for i = 1:num_alphas
       
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
 
    points{i} = getMarkerCentroids(settings);
    
end
save('outputSegment/unordered_points_g2.mat','points');
%save(strcat(folder, 'unordered_points_2.mat', 'points'));