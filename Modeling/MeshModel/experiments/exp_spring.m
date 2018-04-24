% Mesh:                 Bar
% Boundary condition:   Left side fixed
% External force:       Springs attached to corners of right side

clear
addpath('../utils')
load('../meshes/bar_T1197_V325.mat');

method = fem_method();

mesh = method.create_mesh(T, X, Y, Z);
params = create_params('soft');
state = method.create_state(mesh, params);
bcon = bend_create_boundary_conditions(1,state,mesh);

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
mvy = 0;

for i  = 1:500
    state          = method.clear_forces(state);
    %traction_info  = add_external_force(state,mesh, pind, goal_pos, 3000000);
    %state          = method.add_surface_traction(state, traction_info);
    state          = method.compute_elastic_forces(mesh, state, params);
    [state, conv]  = method.semi_implicit_step(0.003, state, bcon, profile);
    if mod(i,50)==0
        my = [my, max(state.x)];
        mvy = [mvy, max(state.vx)];
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

drawForce(state, mesh)
