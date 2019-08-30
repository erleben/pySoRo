function pcloud_out = translateRobot(pcloud, tform, xyz)
%TRANSLATEROBOT Summary of this function goes here
%   Detailed explanation goes here
    locations = pcloud.Location - xyz;
    pcloud_out = pointCloud(locations.*(tform.S*0.8), 'Color', pcloud.Color);
end

