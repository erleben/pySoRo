function [pcloud_out, pc_raw] = getSurfacePointCloud(pc_raw, thresholds, downsample_ratio, r)
%GETSURFACEPOINTCLOUD Summary of this function goes here
%   Detailed explanation goes here
    %   pc_raw = pcread(pcloud_path);
    
    pcloud_out = segmentPcloud(pc_raw, thresholds(1), thresholds(2), thresholds(3), r);
    [model, pcloud_out, out] = pcloudROIPlane(pcloud_out, 0.009);
    pcloud_out = pcdownsample(pcloud_out, 'gridAverage', downsample_ratio);
    
    
end

