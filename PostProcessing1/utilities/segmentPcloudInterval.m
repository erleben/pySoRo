function pc1 = segmentPcloudInterval(pcloud, colorLower, colorUpper)
%SEGMENTPCLOUDINTERVAL Summary of this function goes here
%   Detailed explanation goes here
% Filter red color channel
%
% Segment first point cloud
%
pc_close = findNeighborsInRadius(pcloud, median(pcloud.Location), 0.7);
pc1 = pointCloud(pcloud.Location(pc_close,:),'Color', pcloud.Color(pc_close,:));

% red channel filter
channel1 = (find(pc1.Color(:,1) > colorLower(1)));
pcredLower = pointCloud(pc1.Location(channel1,:), 'Color', pc1.Color(channel1,:));

channel1 = (find(pcredLower.Color(:,1) < colorUpper(1)));
pcredUpper = pointCloud(pcredLower.Location(channel1,:), 'Color', pcredLower.Color(channel1,:));

% green channel filter
channel2 = (find(pcredUpper.Color(:,2) > colorLower(2)));
pcgreenLower = pointCloud(pcredUpper.Location(channel2,:), 'Color', pcredUpper.Color(channel2,:));

channel2 = (find(pcgreenLower.Color(:,2) < colorUpper(2)));
pcgreenUpper = pointCloud(pcgreenLower.Location(channel2,:), 'Color', pcgreenLower.Color(channel2,:));

% blue channel filter
channel3 = (find(pcgreenUpper.Color(:,3) > colorLower(3)));
pcblueLower = pointCloud(pcgreenUpper.Location(channel3,:), 'Color', pcgreenUpper.Color(channel3,:));

channel3 = (find(pcblueLower.Color(:,3) < colorUpper(3)));
pcblueUpper = pointCloud(pcblueLower.Location(channel3,:), 'Color', pcblueLower.Color(channel3,:));

pc1 = pcblueUpper;
end

