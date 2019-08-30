function outpcs = applyRobotTransform(pcs, tform)
%APPLYROBOTTRANSFORM Summary of this function goes here
%   Detailed explanation goes here

% translate robot point cloud
pc2new = pointCloud(pcs.Location-tform.T, 'Color', pcs.Color);
pc2new1 = pointCloud((tform.R1*pc2new.Location')', 'Color', pc2new.Color);
outpcs = pointCloud((tform.R2*pc2new1.Location')', 'Color', pc2new1.Color);
end

