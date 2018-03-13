function markers = getMarkerCentroids(settings)

show_all = true;
with_color = true;
segment = true;

if nargin == 0
    id = '4';
    id = strcat('_',id);
    subid = '4_4';
    subid = strcat('_',subid);
    
    settings = makeSettings(["618204002727", "616205005055"], '../../data/calibration/', id, '../../data/reconstruction/', subid);

end

isObj_1 = getSegments(settings.back_name{1}, settings.fore_name_recon{1}, false, 1);
isObj_2 = getSegments(settings.back_name{2}, settings.fore_name_recon{2}, false, 1);


%Get at list of pointclouds of markers in each cloud
marker_pcs = {};
PC_from = pcread(settings.pc_name_recon{1});
is_marker = detectMarkers(imread(settings.fore_name_recon{1}), isObj_1{1});
marker_pcs{1} = getObjPointclouds(is_marker', PC_from, settings.tex_name_recon{1});

PC_to = pcread(settings.pc_name_recon{2});
is_marker = detectMarkers(imread(settings.fore_name_recon{2}), isObj_2{1});
marker_pcs{2} = getObjPointclouds(is_marker', PC_to, settings.tex_name_recon{2});

%Find their centroids
points = {}; 
num_markers = length(marker_pcs{1});
points{1} = zeros(num_markers,3);
points{2} = zeros(num_markers,3);

for i = 1:2
    for j = 1:num_markers
        points{i}(j,:) = mean(marker_pcs{i}{j}.Location);
    end 
end 

% Find which centroids in points_1 corresponds to which 
% centroids in points_2 by checking all permutations. Pick the 
% permutaion with the smallest squared error
perm = perms(1:num_markers);
se = zeros(length(perm),1);
for ind = 1:length(perm)
    points_1_perm = points{1}(perm(ind,:)',:);
    [R,T] = getTransformParam(points_1_perm, points{2});
    if det(R) == -1
        se(ind) = inf;
    else
        for i = 1:num_markers
            se(ind) = se(ind) + sqrt(sum((points{2}(i,:)-((R*points_1_perm(i,:)')'+T')).^2));
        end
    end
end

[mse, pind] = min(se);
mse=mse/num_markers;
points{1} = points{1}(perm(pind,:)',:);

%Get the transformation to align the two sets
[R,T] = getTransformParam(points{1},points{2});

% Merge the pointclouds
pc_balls_1 = marker_pcs{1}{1};
pc_balls_2 = marker_pcs{2}{1};
for num = 2:num_markers
    pc_balls_1 = pcmerge(pc_balls_1, marker_pcs{1}{num},0.0001);
    pc_balls_2 = pcmerge(pc_balls_2, marker_pcs{2}{num},0.0001);
end

%Visualize the result of applying the transformation on the two pointclouds
if segment
    PC_from = getObjPointclouds(isObj_1, PC_from, settings.tex_name_recon{1});
    PC_from = PC_from{1};
    PC_to = getObjPointclouds(isObj_2, PC_to, settings.tex_name_recon{2});
    PC_to = PC_to{1};
end

if show_all
    P_from = PC_from; 
    P_to = PC_to;
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
    ref_transformed(i,:)=(R*ref_points(i,:)')'+T';
end
ref_transformed_PC = pointCloud(ref_transformed, 'Color', P_from.Color);

pc_balls_2 = pointCloud(P_to.Location,'Color', fliplr(P_to.Color));
PP=pcmerge(ref_transformed_PC,pc_balls_2, 0.0001);
pcshow(PP,'MarkerSize',1);

for i = 1:num_markers
    points{1}(i,:)=(R*points{1}(i,:)')'+T';
end
markers = (points{1}+points{2})/2;
end 