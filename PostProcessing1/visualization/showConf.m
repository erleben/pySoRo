
pname = '../outputOrder/ordered_grabber.csv';

P=load(pname);

figure;

%pc=pcread('/Volumes/TOSHIBA/experiment5/1_732612060774.ply');
%pc2 = pcread('/Volumes/TOSHIBA/experiment5/1_806312060523.ply');
%pcwrite(pc, 'pc1.ply');
%pcwrite(pc2, 'pc2.ply');
pc = pcread('pc1.ply');
pc2 = pcread('pc2.ply');

settings= makeSettings('16');
tform  = load(strcat('../', settings.tform_name));

loc = pc2.Location;
loc = loc*tform.R + tform.T';


pc2 = pointCloud(loc, 'Color', pc2.Color);
merged = pcmerge(pc,pc2,0.0005);

inter = findNeighborsInRadius(merged,median(merged.Location),0.2);
pts = merged.Location(inter,:);

plane = pcfitplane(merged, 0.001);
R=vrrotvec2mat(vrrotvec(plane.Normal, [0,0,-1]));


for i = 1:length(pts)
    pts(i,:) = (R*pts(i,:)')';
end

for i = 1:3:9
    P(:,i:i+2) = (R*P(:,i:i+2)')';
end


merged = pointCloud(pts,'Color',merged.Color(inter,:));
pcshow(merged,'MarkerSize',11);
set(gca, 'ZDir','reverse');
 
% OptionZ.FrameRate=20;OptionZ.Duration=5.5;OptionZ.Periodic=true;
% 
% CaptureFigVid([-20,80;-110,10; -190,80;], 'WellMadeVid1',OptionZ)
% hold on;
% scatter3(P(:,1),P(:,2),P(:,3),10,'f');
% scatter3(P(:,4),P(:,5),P(:,6),10,'f');
% scatter3(P(:,7),P(:,8),P(:,9),10,'f');
% 
% CaptureFigVid([-190,80;-290,30;-380,30], 'WellMadeVid2',OptionZ)
% 
