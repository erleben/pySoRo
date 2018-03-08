function [pind_pc, gp] = labelPoints(T, state, pc)

tri = triangulation(T,state.x, state.y, state.z);
tri_free = triangulation(freeBoundary(tri),tri.Points);



% For each point in the pc, find the nearest vertex in the mesh
goal_pos = double(pc.Location);
pind_pc = zeros(length(goal_pos),1);
for i = 1:length(goal_pos)
    pind_pc(i) = nearestNeighbor(tri_free, goal_pos(i,:));
end

% Remove duplicates
pind_pc = unique(pind_pc);

% For each vertex that is closest to some point, link to its closest point
gp = [];
for i = 1:length(pind_pc)
    p = findNearestNeighbors(pc, tri_free.Points(pind_pc(i),:),1);
    gp(i,:) = pc.Location(p,:);
end

end