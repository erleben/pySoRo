% Step 1:
% Deform bar


% Mesh:                 Bar
% Boundary condition:   Left side fixed
% External force:       Downward pointing traction on right side

clear
addpath('../utils')
load('../meshes/bar_T1197_V325.mat');

method = fem_method();

mesh = method.create_mesh(T, X, Y, Z);
params = create_params('soft');
state = method.create_state(mesh, params);
traction_info = bend_create_surface_traction_info(1, state, mesh);
state = method.add_surface_traction(state, traction_info);
bcon = bend_create_boundary_conditions(1,state,mesh);
profile = true;

my = 0;
mvy = 0;

for i  = 1:500
    state          = method.clear_forces( state );
    traction_info  = bend_create_surface_traction_info( 1, state, mesh );
    state          = method.add_surface_traction( state, traction_info );
    state          = method.compute_elastic_forces(mesh, state,params);
    [state, conv]  = method.semi_implicit_step(0.006, state, bcon, profile);
    if mod(i,50)==0
        my = [my, max(state.x)];
        mvy = [mvy, max(state.vx)];
    end
end


figure()
subplot(2,1,1)
tetramesh(T,[X,Y,Z])
view([0 90])
title('Material');

subplot(2,1,2)
tetramesh(mesh.T,[state.x, state.y, state.z])
view([0 90])
title('Spatial');

drawForce(state,mesh)

%--------------------------------------------------------------------%
% Step 2:
% Use moving dirichlet to force some points in the initial bar towards
% the corresponding points in the deformed bar

% Mesh:                 Bar
% Boundary condition:   Left side fixed
%                       Moving corner points on right side
% External force:       None


mesh    = method.create_mesh(T, X, Y, Z);
params  = create_params('soft');
state_1   = method.create_state(mesh, params);

profile = true;

% Find corner points in inital mesh
xlim =5;
ylim = 2;

goal_pos = [xlim, -ylim, -ylim;...
               xlim, -ylim,  ylim;... 
               xlim,  ylim, -ylim;... 
               xlim,  ylim,  ylim];

tri = triangulation(T,X,Y,Z);
pind = zeros(4,1);
for i = 1:4
    pind(i) = nearestNeighbor(tri, goal_pos(i,:));
end

goal_pos = [state.x(pind), state.y(pind), state.z(pind)];

my = 0;
mvy = [];


for i  = 1:800
    state_1          = method.clear_forces(state_1);
    state_1          = method.compute_elastic_forces(mesh, state_1, params);
    moving_bcon    = moving_dirichlet(min(1,i/200), mesh, pind, goal_pos);
    merged_bcon    = merge_boundary_conditions(bcon, moving_bcon);
    [state_1, conv]  = method.semi_implicit_step(0.003, state_1, merged_bcon, profile);
    if mod(i,50)==0
        my = [my, max(state_1.x)];
        mvy = [mvy, max(state_1.vx)];
        if my(end-1) > my(end)
            %break
        end
    end
end


figure()
subplot(2,1,1)
tetramesh(T,[X,Y,Z])
view([0 90])
title('Material');

subplot(2,1,2)
tetramesh(mesh.T,[state_1.x, state_1.y, state_1.z])
view([0 90])
title('Spatial');

drawForce(state_1, mesh);