function pc_transformed = transformPointCloud(pc, tform)
%TRANSFORMPOINTCLOUD Summary of this function goes here
%   Detailed explanation goes here
    ref_transformed = zeros(pc.Count,3);
    ref_points = pc.Location;
    
    for i = 1:pc.Count
        ref_transformed(i,:)=(tform.R*ref_points(i,:)')'+tform.T';
    end
    pc_transformed = pointCloud(ref_transformed, 'Color', pc.Color);
end

