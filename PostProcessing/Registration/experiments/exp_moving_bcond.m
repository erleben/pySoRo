% Mesh:                 Bar
% Boundary condition:   Left side fixed
%                       Moving corner points on right side
% External force:       None

clear
addpath('../utils')
load('../meshes/bar_T1197_V325.mat');

method = fem_method();

mesh    = method.create_mesh(T, X, Y, Z);
params  = create_params('soft');
state   = method.create_state(mesh, params);

profile = true;

% Create goal position for corner points
xlim =6;
ylim = 3;

goal_pos = [xlim, -ylim, -ylim;...
               xlim, -ylim,  ylim;... 
               xlim,  ylim, -ylim;... 
               xlim,  ylim,  ylim];

tri = triangulation(T,X,Y,Z);
pind = zeros(4,1);
for i = 1:4
    pind(i) = nearestNeighbor(tri, goal_pos(i,:));
end

my = 0;
mvy = [];


for i  = 1:50
    state          = method.clear_forces(state);
    state          = method.compute_elastic_forces(mesh, state, params);
    moving_bcon    = moving_dirichlet(min(1,i/30), mesh, pind, goal_pos);
    merged_bcon    = merge_boundary_conditions(bcon, moving_bcon);
    [state, conv]  = method.semi_implicit_step(0.003, state, merged_bcon, profile);
    if mod(i,50)==0
        my = [my, max(state.x)];
        mvy = [mvy, max(state.vx)];
        if my(end-1) > my(end)
            %break
        end
    end
end


figure()
subplot(2,1,1)
tetramesh(T,[X,Y,Z])
view([0 -90])
title('Material');

subplot(2,1,2)
tetramesh(mesh.T,[state.x, state.y, state.z])
view([0 -90])
title('Spatial');

drawForce(state, mesh);