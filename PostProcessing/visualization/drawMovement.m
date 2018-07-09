

figure;
P = load('../outputOrder/ordered_grabber_g3.csv');
hold on;
pc = pcread('pc1.ply');

inter = findNeighborsInRadius(pc,mean(reshape(P(1,:)',3,size(P,2)/3)'),0.099);
pts = merged.Location(inter,:);
pc = pointCloud(pts,'Color',pc.Color(inter,:));
pcshow(pc,'MarkerSize',80);
set(gca,'Color','k')
e = logical(e);
r = 1:35:1015;
%r = 1:29;
%r = 1:1015
for i = 1:11
est = r(e(r,i));
nest = r(~e(r,i));
%scatter3(P(est,i*3-2),P(est,i*3-1),P(est,i*3),10,'f');
%scatter3(P(nest,i*3-2),P(nest,i*3-1),P(nest,i*3),10,'f');
scatter3(P(r,i*3-2),P(r,i*3-1),P(r,i*3),10,'f');

%legend
end

