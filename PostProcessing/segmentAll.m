% NB: You have to run runCalibration for the current camera setting before
% running this script.
% This script segments the markers on the soft robot and find its xyz
% corrdinates (centers). The segmented data is stored in a MxN mat file
% where M is the number of iterations and N = number of markers *
% dimension of points.

ordered = {};

folder = strcat('/Users/FredrikHolsten/Desktop/Master/culturenight/culturenight'); %Where the data can be found
settings = makeSettings('21');                                                     %Postfix of calibration names
num_alphas = 231;                                                                  %The number of configurations
save_as = 'outputSegment/culturenight_unordered_2.mat';                            %Path + file name of result

for i = 1:num_alphas
       
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
 
    points{i} = getMarkerCentroids(settings);
    
end

save(save_as,'points');
