function [pcloud1, pcloud2, mergedPointCloud] = getMarkerCentroids(settings, tform, thresholds, r, downsample_ratio)
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
    pc1_raw = pcread(settings.pc_name_recon{1});
    pc1_raw = pcdownsample(pc1_raw, 'gridAverage', downsample_ratio);
    pcloud1 = segmentPcloud(pc1_raw, thresholds(1), thresholds(2), thresholds(3), r);
    [pcloud1, out] = pcloudROIPlane(pcloud1, 0.009);
    pc2_raw = pcread(settings.pc_name_recon{2});
    pc2_raw = pcdownsample(pc2_raw, 'gridAverage', downsample_ratio);
    pcloud2 = segmentPcloud(pc2_raw, thresholds(1), thresholds(2), thresholds(3), r);
    [pcloud2, out] = pcloudROIPlane(pcloud2, 0.009);
    
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
    [mergedPointCloud, out] = pcloudROIPlane(mergedPointCloud, 0.009);
    
    pcloud1 = pointCloud((pcloud1.Location).*tform.S, 'Color', pcloud1.Color);
    x = pcloud1.Location(:,1) - min(pcloud1.Location(:,1));
    y = pcloud1.Location(:,2) - min(pcloud1.Location(:,2));
    z = pcloud1.Location(:,3) - min(pcloud1.Location(:,3));
    pcloud1 = pointCloud([x, y, z], 'Color', pcloud1.Color);
    
    
    pcloud2 = pointCloud((pcloud2.Location).*tform.S, 'Color', pcloud2.Color);
    x = pcloud2.Location(:,1) - min(pcloud2.Location(:,1));
    y = pcloud2.Location(:,2) - min(pcloud2.Location(:,2));
    z = pcloud2.Location(:,3) - min(pcloud2.Location(:,3));
    pcloud2 = pointCloud([x, y, z], 'Color', pcloud2.Color);
    
    mergedPointCloud = pointCloud((mergedPointCloud.Location).*tform.S, 'Color', mergedPointCloud.Color);
    x = mergedPointCloud.Location(:,1) - min(mergedPointCloud.Location(:,1));
    y = mergedPointCloud.Location(:,2) - min(mergedPointCloud.Location(:,2));
    z = mergedPointCloud.Location(:,3) - min(mergedPointCloud.Location(:,3));
    mergedPointCloud = pointCloud([x, y, z], 'Color', mergedPointCloud.Color);
    %mergedPointCloud = pcloud1;
    
end

