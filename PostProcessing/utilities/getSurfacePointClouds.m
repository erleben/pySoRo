function [pcloud1, pcloud2, mergedPointCloud] = getMarkerCentroids(settings, tform, thresholds, r)
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
    pc1_raw = pcread(settings.pc_name_recon{1});
    pcloud1 = segmentPcloud(pc1_raw, thresholds(1), thresholds(2), thresholds(3), r);
    pc2_raw = pcread(settings.pc_name_recon{2});
    pcloud2 = segmentPcloud(pc2_raw, thresholds(1), thresholds(2), thresholds(3), r);
    
    % Transforming pc1 into unit space of camera pc2
    % Given transformation matrix tform.R and tform.T
    ref_transformed = zeros(pc1_raw.Count,3);
    ref_points = pc1_raw.Location;
    for i = 1:pc1_raw.Count
        ref_transformed(i,:)=(tform.R*ref_points(i,:)')'+tform.T';
    end
    pc1_transformed = pointCloud(ref_transformed, 'Color', pc1_raw.Color);
    pc_close = findNeighborsInRadius(pc1_transformed, median(pc1_transformed.Location), 0.5);
    pc1_transformed = pointCloud(pc1_transformed.Location(pc_close,:),'Color', pc1_transformed.Color(pc_close,:));
    pcmerged_raw = pcmerge(pc1_transformed, pc2_raw, 0.00001);    
    mergedPointCloud = segmentPcloud(pcmerged_raw, thresholds(1), thresholds(2), thresholds(3), r);
    %mergedPointCloud = pcloud1;
    
end

