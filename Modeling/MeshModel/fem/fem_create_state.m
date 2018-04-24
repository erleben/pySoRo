function [ state ] = fem_create_state( mesh, params )
% Copyright 2011, Kenny Erleben

T = length(mesh.T(:,1));   % Number of tetrahedrons
V = length(mesh.x0);       % Number of vertices

k   = zeros(V*3, 1);       % Allocate global elastic force vector

vx = zeros(V,1);           % Velocity field
vy = zeros(V,1);
vz = zeros(V,1);

fx = zeros(V,1);           % External force field
fy = zeros(V,1);
fz = zeros(V,1);

x  = mesh.x0;              % Spatial coordintes (initialized to be equal to material coordiantes)
y  = mesh.y0;
z  = mesh.z0;

Me    = fem_compute_mass_elements( mesh, params );
M     = sparse( fem_assemble_global_matrix( mesh, Me ) );

Ce    = fem_compute_damping_elements( mesh, params );
C     = sparse( fem_assemble_global_matrix( mesh, Ce ) );

state = struct(   'x',  x, 'y', y, 'z', z,...
  'vx', vx, 'vy', vy, 'vz', vz,...
  'fx', fx, 'fy', fy, 'fz', fz,...  
  'k', k, 'C', C, 'M', M...
  );

end