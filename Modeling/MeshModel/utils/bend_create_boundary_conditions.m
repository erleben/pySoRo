function [ BC ] = bend_create_boundary_conditions( time, state, mesh )
%BEND_CREATE_BOUNDARY_CONDITIONS -- Creates a fixed position boundary condition.
%
% INPUT:
%
%   time   - The current simulated time.
%   state  - The current state.
%   mesh   - The initial  mesh.
%
% OUTPUT:
%
% BC    - Upon return this struct will hold indices and values for the
%         wanted boundary conditions.
%
% Copyright 2011, Kenny Erleben

x = mesh.x0;
y = mesh.y0;
z = mesh.z0;

% Get mesh dimensions
%max_x            = max( x );
min_x            = min( x );
max_y            = max( y );
min_y            = min( y );
max_z            = max( z );
min_z            = min( z );
delta            = 0.01;

box = [...
  min_x-delta, min_y-delta,...
  min_z-delta, min_x+delta,...
  max_y+delta, max_z+delta...
  ];

x_min = box(1) .* ones( size( x ) );
y_min = box(2) .* ones( size( y ) );
z_min = box(3) .* ones( size( z ) );

x_max = box(4) .* ones( size( x ) );
y_max = box(5) .* ones( size( y ) );
z_max = box(6) .* ones( size( z ) );

I = find( (x_min<x)&(x<x_max)&(y_min<y)&(y<y_max)&(z_min<z)&(z<z_max) );

xoffset = 0;
yoffset = length(x);
zoffset = 2*length(x);

idx    = [I+xoffset; I+yoffset; I+zoffset];
values = [x(I); y(I); z(I) ];

BC = struct( 'idx', idx,...
  'values', values...
  );

end