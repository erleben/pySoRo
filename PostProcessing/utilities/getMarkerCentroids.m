function labeled_points = getMarkerCentroids(settings, tform)

show_pin_seg = false;
max_distance = 0.011; % Max allowed distance bettween linked markers

if nargin < 2
    tform = load(settings.tform_name);
end


% Get labeled images: robot/background
isObj_1 = getSegments(settings.back_name{1}, settings.fore_name_recon{1}, false, 1)>0;
isObj_2 = getSegments(settings.back_name{2}, settings.fore_name_recon{2}, false, 1)>0;
 
 
% Get at list of pointclouds of markers in each cloud
marker_pcs = {};
PC_from = pcread(settings.pc_name_recon{1});
foreground = imread(settings.fore_name_recon{1});
% Get labeled images: markers/background
is_marker = detectMarkers(foreground, isObj_1, show_pin_seg, 6);
marker_pcs{1} = getObjPointclouds(is_marker, PC_from, settings.tex_name_recon{1});

PC_to = pcread(settings.pc_name_recon{2});
foreground = imread(settings.fore_name_recon{2});
% Get labeled images: markers/background
is_marker = detectMarkers(foreground, isObj_2, show_pin_seg, 6);
marker_pcs{2} = getObjPointclouds(is_marker, PC_to, settings.tex_name_recon{2});
  
%Find their centroids
points = {}; 
num_markers = length(marker_pcs{1});
points{1} = zeros(num_markers,3);
points{2} = zeros(length(marker_pcs{2}),3); 
 
for i = 1:2
    for j = 1:length(marker_pcs{i})
        points{i}(j,:) = mean(marker_pcs{i}{j}.Location);
    end 
end 


% Use the calibration tform to put them in same coordiante system
close_points = zeros(num_markers,3);
for i = 1:num_markers
    close_points(i,:)=(tform.R*points{1}(i,:)')'+tform.T';
end 
   
% Group the markers into points seen by 1) both cameras and 2) only one of them
labeled_points = group_markers(close_points, points, max_distance);

disp('Common:')
disp(size(labeled_points.common,1));
disp('Exclusive:')
disp(size(labeled_points.exclusive,1));

end
