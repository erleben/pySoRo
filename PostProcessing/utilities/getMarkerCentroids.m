function labeled_points = getMarkerCentroids(settings, tform)

with_color = false;
segment = false;
show_pin_seg = false;
max_distance = 0.011; % Max allowed distance bettween linked markers
with_pc = false;

if nargin < 1
    settings = makeSettings('8','5');
end

if nargin < 2
    tform = load(settings.tform_name);
end


% Get labeled images: foreground/background
isObj_1 = getSegments(settings.back_name{1}, settings.fore_name_recon{1}, false, 2)>0;
isObj_2 = getSegments(settings.back_name{2}, settings.fore_name_recon{2}, false, 2)>0;

 
% Get at list of pointclouds of markers in each cloud
marker_pcs = {};
PC_from = pcread(settings.pc_name_recon{1});
is_marker = detectMarkers(imread(settings.fore_name_recon{1}), isObj_1, show_pin_seg, 5);
marker_pcs{1} = getObjPointclouds(is_marker, PC_from, settings.tex_name_recon{1});

PC_to = pcread(settings.pc_name_recon{2});
is_marker = detectMarkers(imread(settings.fore_name_recon{2}), isObj_2, show_pin_seg, 4);
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


% Use the calibration estimate to put them in same coordiante system
close_points = zeros(num_markers,3);
for i = 1:num_markers
    close_points(i,:)=(tform.R*points{1}(i,:)')'+tform.T';
end 
   
% Group the markers into points seen by both cameras and only one of them
% Find a better transformation
labeled_points = group_markers(close_points, points, max_distance);

disp('Common:')
disp(size(labeled_points.common,1));
disp('Exclusive:')
disp(size(labeled_points.exclusive,1));

if with_pc
    % Merge the pointclouds
    pc_balls_1 = marker_pcs{1}{1};
    pc_balls_2 = marker_pcs{2}{1};
    for num = 2:length(marker_pcs{1})
        pc_balls_1 = pcmerge(pc_balls_1, marker_pcs{1}{num},0.0001);
    end
    
    for num = 2:length(marker_pcs{2})
        pc_balls_2 = pcmerge(pc_balls_2, marker_pcs{2}{num},0.0001);
    end

    %Visualize the result of applying the transformation on the two pointclouds
    if segment
        P_from = getObjPointclouds(isObj_1, PC_from, settings.tex_name_recon{1});
        P_from = P_from{1};
        P_to = getObjPointclouds(isObj_2, PC_to, settings.tex_name_recon{2});
        P_to = P_to{1};
    else
        P_from = pc_balls_1;
        P_to = pc_balls_2;
    end

    if ~with_color
        P_from = pointCloud(P_from.Location);
        P_to = pointCloud(P_to.Location);
    end



    figure;
    ref_transformed = zeros(P_from.Count,3);
    ref_points = P_from.Location;
    for i = 1:P_from.Count
        ref_transformed(i,:)=(tform.R*ref_points(i,:)')'+tform.T';
    end
    ref_transformed_PC = pointCloud(ref_transformed, 'Color', P_from.Color);
 
    pc_balls_2 = pointCloud(P_to.Location,'Color', fliplr(P_to.Color));
    PP=pcmerge(ref_transformed_PC,pc_balls_2, 0.0001);
    pcshow(PP,'MarkerSize',10);
    hold on;
    
    sz = 180;
    scatter3(labeled_points.exclusive(:,1),labeled_points.exclusive(:,2),labeled_points.exclusive(:,3),sz);
    scatter3(labeled_points.common(:,1),labeled_points.common(:,2),labeled_points.common(:,3),sz);
    legend('Merged pointcloud','Exclusive', 'Common');
    
    
    %save('../Registration/sponge.mat','PP');
end 
end