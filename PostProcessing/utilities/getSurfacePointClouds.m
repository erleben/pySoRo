function [pcloud1, pcloud2, mergedPointCloud] = getSurfacePointClouds(settings, tform, thresholds, r, downsample_ratio, offset)
    %GETSURFACEPOINTCLOUDS Summary of this function goes here
    %   Detailed explanation goes here
    with_color = false;
    segment = false;
    show_pin_seg = false;
    max_distance = 0.011; % Max allowed distance bettween linked markers
    with_pc = false;

    if nargin < 1
        settings = makeSettings('4');
    end
    if nargin < 2
        tform = load(settings.tform_name);
    end
    if nargin < 3
        thresholds = [100; 100; 100];
    end 
    if nargin < 4
        r = 0.2;
    end 
    if nargin < 5
        downsample_ratio = 0.001;
    end
    if nargin < 6
        offset = [0,0,0];
    end 
    % Segment the two different pointclouds
    [pcloud1, pc1_raw] = getSurfacePointCloud(pcread(settings.pc_name_recon{1}), thresholds, downsample_ratio, r);
    pcloud1 = transformPointCloud(pcloud1, tform);
    pc1_raw = transformPointCloud(pc1_raw, tform);
    [pcloud2, pc2_raw] = getSurfacePointCloud(pcread(settings.pc_name_recon{2}), thresholds, downsample_ratio, r);
    % Merged the two raw point clouds.
    
    %pcmerged_raw = mergeRobotPointClouds(pc1_raw, pc2_raw, tform);
    pcmerged_raw = pcmerge(pc1_raw, pc2_raw, 0.00001);
    [mergedPointCloud, pcmerged_raw] = getSurfacePointCloud(pcmerged_raw, thresholds, downsample_ratio, r);
    
   pcloud1 = translateRobot(pcloud1, tform, offset); % ...
%                             [min(pcloud1.Location(:,1)), ...
%                              min(pcloud1.Location(:,2)), ...
%                              min(pcloud1.Location(:,3))]);

   pcloud2 = translateRobot(pcloud2, tform, offset); %...
%                             [min(pcloud2.Location(:,1)), ...
%                              min(pcloud2.Location(:,2)), ...
%                              min(pcloud2.Location(:,3))]);


   mergedPointCloud = translateRobot(mergedPointCloud, tform, offset); % ...
%                             [min(mergedPointCloud.Location(:,1)), ...
%                              min(mergedPointCloud.Location(:,2)), ...
%                              min(mergedPointCloud.Location(:,3))]);

end

