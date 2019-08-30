function pc_merged = mergeRobotPointClouds(pc1, pc2, tform)
%MERGEROBOTPOINTCLOUDS Summary of this function goes here
    % Transforming pc1 into unit space of camera pc2
    % Given transformation matrix tform.R and tform.T

    ref_transformed = zeros(pc1.Count,3);
    ref_points = pc1.Location;
    
    for i = 1:pc1.Count
        ref_transformed(i,:)=(tform.R*ref_points(i,:)')'+tform.T';
    end
    pc1_transformed = pointCloud(ref_transformed, 'Color', pc1.Color);
    
end

