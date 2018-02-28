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

drawForce(state,mesh)
