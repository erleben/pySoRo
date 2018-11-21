% NB: You have to run runCalibration for the current camera setting before
% running this script.
% This script segments the markers on the soft robot and find its xyz
% corrdinates (centers). The segmented data is stored in a MxN mat file
% where M is the number of iterations and N = number of markers *
% dimension of points.


folder = strcat('D:\\nuc_finger1\\'); %The loactoin of your data
settings = makeSettings('2');  %Specify the prefix of the calibratoin
num_alphas = 54;    %The number of configurations 
save_as = 'outputSegment/finger_nuc_konstantin.mat'; %Path + file name of result


% The script will display 
% 1) Common: The number of markers seen by both sensors
% 2) Exclusive: The number of markers seen by only one sensor
% If you have N markers, then ideally, you have N common markers in each
% frame. This is not very likely, but if you see that the number of common
% markers is constantly low, you might want to see what is wrong. 
% 1) Check if the robot/background segmentation is good: 
%          Set a breakpoint in getMarkerCentroids arger isObj1 and isObj2
%          has been created. Run segmentAll. When the script stops, display
%          the segmentations with imagesc(isObj1) and imagesc(isObj2).
%          You should be able to see the contour of the robot. If that is
%          not the case, set a breakpoint in getSegments and display some
%          of the intermediate images, like imagesc(HSV(:,:,3)). This can
%          give you an idea of what is wrong. You have now two options: You
%          can either tweak the hardcoded parameters used for segmentation
%          OR redo the data acqusition with better light conditions/camera
%          settings.
% 2) The robot/background segmentation is ok, but the marker/robot
% segmentation is not. Do as above, excet that you look into is_marker and
% detectMarkers() instead.

ordered = {};
                                                             
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
