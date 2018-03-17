function labeled_points = getMarkerCentroids(settings)

%TODO: order labeled_markers wrt prev_labeled_markers 

with_color = true;
segment = false;
show_pin_seg = false;
max_distance = 0.05; % Max allowed distance bettween linked markers
with_pc = false;

if nargin == 0
    id = '8';
    id = strcat('_',id);
    subid = '8_5';
    subid = strcat('_',subid);
    
    settings = makeSettings(["618204002727", "616205005055"], '../../data/calibration/', id, '../../data/reconstruction/', subid);

end

% Get labeled images
isObj_1 = getSegments(settings.back_name{1}, settings.fore_name_recon{1}, false, 1);
isObj_2 = getSegments(settings.back_name{2}, settings.fore_name_recon{2}, false, 1);

 
% Get at list of pointclouds of markers in each cloud
marker_pcs = {};
PC_from = pcread(settings.pc_name_recon{1});
is_marker = detectMarkers(imread(settings.fore_name_recon{1}), isObj_1{1}, show_pin_seg);
marker_pcs{1} = getObjPointclouds(is_marker', PC_from, settings.tex_name_recon{1});

PC_to = pcread(settings.pc_name_recon{2});
is_marker = detectMarkers(imread(settings.fore_name_recon{2}), isObj_2{1}, show_pin_seg);
marker_pcs{2} = getObjPointclouds(is_marker', PC_to, settings.tex_name_recon{2});
  
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


% Use the calibration to put them in same coordiante system
tform = load(settings.tform_name);
close_points = zeros(num_markers,3);
for i = 1:num_markers
    close_points(i,:)=(tform.R*points{1}(i,:)')'+tform.T';
end 
 
[labeled_points, new_tform, success_flag, mse] = group_markers(close_points, points, max_distance);
disp('mse:')
disp(mse);
disp('success_flag: ')
disp(success_flag);
% For now: If we dont have enough points to make a good alignment,
% use the base-calibration
if ~success_flag
    new_tform = tform;
    %Setback points too
end 
 
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
        ref_transformed(i,:)=(new_tform.R*ref_points(i,:)')'+new_tform.T';
    end
    ref_transformed_PC = pointCloud(ref_transformed, 'Color', P_from.Color);

    pc_balls_2 = pointCloud(P_to.Location,'Color', fliplr(P_to.Color));
    PP=pcmerge(ref_transformed_PC,pc_balls_2, 0.0001);
    pcshow(PP,'MarkerSize',100);
    hold on;
    
    sz = 180;
    scatter3(labeled_points.exclusive(:,1),labeled_points.exclusive(:,2),labeled_points.exclusive(:,3),sz);
    scatter3(labeled_points.common(:,1),labeled_points.common(:,2),labeled_points.common(:,3),sz);
    legend('Merged pointcloud','Exclusive', 'Common');
    
    
    save('../Registration/sponge.mat','PP');
end
end 