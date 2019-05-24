function a = visualizepcloud2d(pcloud)
%VISUALIZEPCLOUD2D Summary of this function goes here
%   Detailed explanation goes here
% Depth map
a=1;
figure();
cmap = pcloud.Location(:,3);
scatter(pcloud.Location(:,1), pcloud.Location(:,2), 10, cmap, 'filled');
figure();
cmap = pcloud.Color./255;
scatter(pcloud.Location(:,1), pcloud.Location(:,2), 10, cmap, 'filled');
end

