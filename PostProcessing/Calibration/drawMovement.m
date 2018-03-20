
from = ordered{1}.all;


figure;
scatter3(from(:,1),from(:,2),from(:,3),'b','f');
hold on;

%from_e = ordered{1}.exclusive;
%scatter3(from_e(:,2),from_e(:,3),from_e(:,4),'b','f');

for i = 2:length(ordered)
    pts = ordered{i}.all;
    scatter3(pts(:,1),pts(:,2),pts(:,3),'b','f');
    scatter3(pts(ordered{i}.estimated,1),pts(ordered{i}.estimated,2),pts(ordered{i}.estimated,3),'r','f');
    
    ppts = pts(1:size(from,1),1:size(from,2));
    move = ppts - from;
    scale = 0;
    quiver3(from(:,1),from(:,2),from(:,3), move(:,1),move(:,2),move(:,3),scale,'k');
    from = pts;
   
%     pts_e = ordered{i}.exclusive;
%     scatter3(pts_e(:,2),pts_e(:,3),pts_e(:,4),'b','f');
%     move_e = pts_e - from_e;
%     scale = 0;
%     quiver3(from_e(:,2),from_e(:,3),from_e(:,4), move_e(:,2),move_e(:,3),move_e(:,4),scale,'k');
%     from_e = pts_e;
end