clear;
method = fem_method();

%Load the mesh of a parfect bar, roughly the same size as the pointcloud
mesh=load('mesh.mat');
mesh = mesh.meshh;




% Load the pointcloud
pc = load('barpc.mat');
pc = pc.pc;
pc = pcdownsample(pc,'GridAverage',0.012);
pc = pcdenoise(pc,'Threshold', 0.3);




% Align pc to mesh bar
mesh_pc= pointCloud([mesh.x0, mesh.y0, mesh.z0]);
tform = pcregrigid(pc, mesh_pc);
pc = pctransform(pc, tform);

pc = pointCloud(pc.Location * 100);
mesh.x0 = mesh.x0 * 100;
mesh.y0 = mesh.y0 * 100;
mesh.z0 = mesh.z0 * 100;
mesh = method.create_mesh(mesh.T, mesh.x0, mesh.y0, mesh.z0);
%Take only free vertices of the bar

 
profile = true;

params  = create_params('soft');
state   = method.create_state(mesh, params);
bcon = bend_create_boundary_conditions(1,state,mesh);

[pind_pc, gp] = labelPoints(mesh.T, state, pc);

oldSumForces = inf;

for i  = 1:1000
    state          = method.clear_forces(state);
    
    [traction_info, state]  = add_external_force(state, mesh, pind_pc, gp, 1000000, false);
    state          = method.add_surface_traction(state, traction_info);
    state          = method.compute_elastic_forces(mesh, state, params);
    %moving_bcon    = moving_dirichlet(min(1,i/10), mesh, pind, goal_pos);
    %merged_bcon    = merge_boundary_conditions(bcon, moving_bcon);
    merged_bcon = bcon;
    [state, conv]  = method.semi_implicit_step(0.0002, state, merged_bcon, profile);
    
    sumForces = sum(sqrt(state.fx.^2+state.fy.^2+state.fz.^2))
    if oldSumForces < sumForces
        break
    end
    oldSumForces = sumForces;
    
    if mod(i+29,30) == 0
        hold off;
        drawForce(state, mesh, pc, 1);
        drawnow
        %[pind_pc, gp] = labelPoints(mesh.T, state, pc);

    end
        
end    
   

figure() 
subplot(2,1,1)
tetramesh(mesh.T,[mesh.x0,mesh.y0,mesh.z0])
view([0 90])
title('Material'); 

subplot(2,1,2) 
tetramesh(mesh.T,[state.x, state.y, state.z])
view([0 90])
title('Spatial');

figure;
drawForce(state, mesh, pc);
