function [ BC ] = moving_dirichlet( time, mesh, bcon_ind, attachments)
%BEND_CREATE_BOUNDARY_CONDITIONS -- Creates a fixed position boundary condition.
%
% INPUT:
%
%   time   - The current simulated time in the range (0,1)
%   state  - The current state.
%   mesh   - The initial  mesh.
%   bcon_ind   - The point indices of the moving boundary points
%   attachments - Goal position of the moving boundary
%
% OUTPUT:
%
% BC    - Upon return this struct will hold indices and values for the
%         wanted boundary conditions.
%
% Copyright 2011, Kenny Erleben

% The new position will lie on the line between the initial point and 
% the goal point

x = mesh.x0;
y = mesh.y0;
z = mesh.z0;


xoffset = 0;
yoffset = length(x);
zoffset = 2*length(x);

idx    = [bcon_ind+xoffset; bcon_ind+yoffset; bcon_ind+zoffset];
values = [x(bcon_ind); y(bcon_ind); z(bcon_ind) ];

L = reshape(attachments, numel(attachments), 1) - values;

% Set the new positions of the moving boundary points
values = values + time * L;

BC = struct( 'idx', idx,...
  'values', values...
  );

end