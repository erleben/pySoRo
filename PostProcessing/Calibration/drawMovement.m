
from = ordered{1}.common;


figure;
scatter3(from(:,2),from(:,3),from(:,4),'r','f');
hold on;

from_e = ordered{1}.exclusive;
scatter3(from_e(:,2),from_e(:,3),from_e(:,4),'b','f');

for i = 2:length(ordered)
    pts = ordered{i}.common;
    scatter3(pts(:,2),pts(:,3),pts(:,4),'r','f');
    move = pts - from;
    scale = 0;
    quiver3(from(:,2),from(:,3),from(:,4), move(:,2),move(:,3),move(:,4),scale,'k');
    from = pts;
    
    pts_e = ordered{i}.exclusive;
    scatter3(pts_e(:,2),pts_e(:,3),pts_e(:,4),'b','f');
    move_e = pts_e - from_e;
    scale = 0;
    quiver3(from_e(:,2),from_e(:,3),from_e(:,4), move_e(:,2),move_e(:,3),move_e(:,4),scale,'k');
    from_e = pts_e;
end