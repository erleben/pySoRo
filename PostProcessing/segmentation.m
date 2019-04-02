%Visualization program
addpath('utilities/');

folder = strcat('/Users/NewUser/Documents/experiment1/');
settings = makeSettings('4');

%pc = imread(strcat(folder, '1_821312062271color.tif'));
%pc = imread(strcat(folder, '1_821312062271texture.tif'));
pc = pcread(strcat(folder, '1_821312062271.ply'));
pc_close = findNeighborsInRadius(pc, median(pc.Location), 0.9);
pc1 = pointCloud(pc.Location(pc_close,:),'Color', pc.Color(pc_close,:));

%length(find(pc1.Color < 10));
%%
channel1 = (find(pc1.Color(:,1) > 242));
pc2 = pointCloud(pc1.Location(channel1,:), 'Color', pc1.Color(channel1,:));

channel2 = (find(pc2.Color(:,2) > 242));
pc3 = pointCloud(pc2.Location(channel2,:), 'Color', pc2.Color(channel2,:));

channel3 = (find(pc3.Color(:,2) > 242));
pc4 = pointCloud(pc3.Location(channel3,:), 'Color', pc3.Color(channel3,:));

pc_close = findNeighborsInRadius(pc4, median(pc4.Location), 0.25);
pc5 = pointCloud(pc4.Location(pc_close,:),'Color', pc4.Color(pc_close,:));

%%
a = im2double(pc5.Color);
b = rgb2gray(a);

grayscale_mask = find(b(:,1) > 0.9);

pc6 = pointCloud(pc5.Location(grayscale_mask,:),'Color', pc5.Color(grayscale_mask,:)./10);


%%


%%
hold on;
%figure();
%pcshow(pc.Location(:));
%pcshow(pc5);
%pcshow(pc3);
%pcshow([pc4.Location(:,1), pc4.Location(:,2), pc4.Location(:,3)]);
%pcshow([pc5.Location(:,1), pc5.Location(:,2), pc5.Location(:,3)]);
%pcshow([pc6.Location(:,1), pc6.Location(:,2), pc6.Location(:,3)]);
pcshow(pc6);
hold off;

%%
D = imread(strcat(folder, '1_821312062271color.tif'));
imshow(D);


