function dist = distpc(p, pc)

pts=findNearestNeighbors(pc,p,3);
pts = mean(pc.Location(pts,:),1);

dist = norm(p-pts);
end