function [model, pcloud_in, pcloud_out] = pcloudROICylinder(pcloud, maxdistance)
%PCLOUDROICYLINDER Summary of this function goes here
%   Detailed explanation goes here
    %centered_location = pcloud.Location - mean(pcloud.Location);
    tmp_locations = pcloud.Location - mean(pcloud.Location);
    pc = pointCloud(tmp_locations, 'Color', pcloud.Color);
    [model,inlierIndices, outlierIndices] = pcfitplane(pc,maxdistance);
    pcloud_in = select(pcloud,inlierIndices);
    pcloud_out = select(pcloud, outlierIndices);
end

