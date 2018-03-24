% Mesh:                 Bar
% Boundary condition:   Left side fixed
% External force:       Downward pointing traction on right side

clear
addpath('../utils')
load('../meshes/bar_T1197_V325.mat');

method = fem_method();

mesh = method.create_mesh(T, X, Y, Z);
params = create_params('soft');

CP = {};
cpts = {};
alphas = [];
ind = 1;
for r_y = 0:0.5:7
    for r_z  =0:0.5:7
        TF_Y = -r_y*1000;
        TF_Z = -r_z*1000;
        alphas = [alphas, [TF_Y;TF_Z]];
        
        state = method.create_state(mesh, params);
        traction_info = bend_create_surface_traction_info(1, state, mesh, TF_Y, TF_Z);
        state = method.add_surface_traction(state, traction_info);
        bcon = bend_create_boundary_conditions(1,state,mesh);
        profile = true;
        
        m = 0;
        mv = 0;

        
        
        for i  = 1:1500
            state          = method.clear_forces( state );
            traction_info  = bend_create_surface_traction_info( 1, state, mesh, TF_Y, TF_Z );
            state          = method.add_surface_traction( state, traction_info );
            state          = method.compute_elastic_forces(mesh, state,params);
            [state, conv]  = method.semi_implicit_step(0.005, state, bcon, profile);
            if mod(i,10)==0
                dist = pdist2([mean(mesh.y0), mean(mesh.z0)], [mean(state.y), mean(state.z)]);
                if m(end)>dist
                    break;
                end
                m = [m, dist];

            end
        end
        
        cpts{ind} = state;
        ind = ind + 1;
    end
    
    
    
    figure()
    % subplot(2,1,1)
    % tetramesh(T,[X,Y,Z])
    % view([0 -90])
    % title('Material');
    
    subplot(2,1,2)
    tetramesh(mesh.T,[state.x, state.y, state.z])
    view([0 -90])
    title('Spatial');
    
    drawForce(state,mesh)
end

CP.states = cpts;
CP.mesh = mesh;
CP.alphas = alphas;
save('CP_two_param_many.mat','CP');
