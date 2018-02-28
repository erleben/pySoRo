function [ Ce ] = fem_compute_damping_elements( mesh, params )
% Copyright 2011, Kenny Erleben

% Get number of elements
E = length(mesh.T(:,1));

Ce = zeros(12,E*12);    % Allocate array of element damping matrices

if params.use_lumped
  % Lumped damping matrix
  NN = eye(12,12) / 4.0;
else
  % Consistent damping matrix
  %
  %  Ce = c V / 20  *  [ 2*I_3x3    I_3x3   I_3x3   I_3x3;
  %                          I_3x3  2*I_3x3   I_3x3   I_3x3;
  %                          I_3x3    I_3x3 2*I_3x3   I_3x3;
  %                          I_3x3    I_3x3   I_3x3 2*I_3x3;]
  %
  %
  NN = (eye(12,12) + repmat( eye(3,3), 4, 4)) / 20.0;  
end

for e=1:E
  Ce( 1:12, (12*(e-1)+1) :(12*e)) =  mesh.V(e)*params.c*NN;
end


end