function [tform, outpcs] = getRobotTransform(pcs,t)
%GETROBOTTRANSFORM Summary of this function goes here
%   Detailed explanation goes here
    
    % Identify base of robot, the left most pixels qualifying as the robot
    % along the x axis.
    location = pcs.Location;
    new = location(:,1) < -10;
    pc = pointCloud(location(new,:), 'Color', pcs.Color(new,:));
    pc_close = findNeighborsInRadius(pc, mean(pc.Location), 5.0);
    pc = pointCloud(pc.Location(pc_close,:), 'Color', pc.Color(pc_close,:)*0);
    
    % translate robot to origin of the coordinate system.
    translation = mean(pc.Location);
    tform.T = translation;
    pc2new = pointCloud(pcs.Location-translation, 'Color', pcs.Color);
    
    % Identify plane orientation of robot surface.
    [model, pcloud_out, out] = pcloudROIPlane(pc2new, 0.1);
    r1 = model.Normal;

    % orthogonal vectors to r1
    l = pc2new.Location;
    a = [];
    a1 = [];
    
    % Identify what we deem to be the exterior side of the surface point
    % cloud.
    for i = 1:length(l)
        p1 = l(i,:);
        angle = atan2(norm(cross(p1, r1)), dot(p1, r1));
        if radtodeg(angle) < 90
            a = [a; i];
        else
            a1 = [a1; i];
        end
    end
    if length(a) < length(a1)
        r1 = r1*-1;
        model = planeModel([model.Normal*-1, model.Parameters(4)]);
    end
    
    % Rotating plane orientation to 0 1 0.
    r = vrrotvec2mat(vrrotvec(model.Normal,[0 1 0]));
    pc2new1 = pointCloud((r*pc2new.Location')', 'Color', pc2new.Color);
    tform.R1 = r;
    
    % Point cloud orientation in x z axises after transformation.
    location = pc2new1.Location;
    Pz = polyfit(location(:,1), location(:,3), 1);
    
    % Identify rotation for point cloud to point toward 1 0 0
    v1 = [1 0 Pz(1)];
    v1 = v1/norm(v1);
    r1 = vrrotvec2mat(vrrotvec(v1,[1 0 0]));
    outpcs = pointCloud((r1*pc2new1.Location')', 'Color', pc2new1.Color);
    tform.R2 = r1;

end

