function [ Me ] = fem_compute_mass_elements( mesh, params )
% Copyright 2011, Kenny Erleben

% Get number of elements
E = length(mesh.T(:,1));

Me = zeros(12,E*12);    % Allocate array of element mass matrices

if params.use_lumped
  % Lumped mass matrix
  NN = eye(12,12) / 4.0;
  
else
  
  % Consistent mass matrix
  %
  %  Me = rho V / 20  *  [ 2*I_3x3    I_3x3   I_3x3   I_3x3;
  %                          I_3x3  2*I_3x3   I_3x3   I_3x3;
  %                          I_3x3    I_3x3 2*I_3x3   I_3x3;
  %                          I_3x3    I_3x3   I_3x3 2*I_3x3;]
  %
  %
  NN = (eye(12,12) + repmat( eye(3,3), 4, 4)) / 20.0;
  
end

% Now compute element stiffness matrices
for e=1:E
  Me( 1:12, (12*(e-1)+1) :(12*e)) =  mesh.V(e)*params.rho*NN;
end

end