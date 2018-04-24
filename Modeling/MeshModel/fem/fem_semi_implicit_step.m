function [ state, conv ] = fem_semi_implicit_step(dt, state, bcon, profile)
% Copyright 2011, Kenny Erleben

%--- Assemble all vector and matrices needed ------------------------------
k    =   state.k;                        % Elastic forces
f    = [ state.fx; state.fy; state.fz];  % External forces
p    = [ state.x; state.y; state.z];     % Current spatial position
v    = [ state.vx; state.vy; state.vz];  % Current spatial velocity

Atmp    = state.M;
btmp    = state.M*v + dt*(f - k - state.C*v );

%--- Get information about boundary conditions ----------------------------
V      = length( state.x );      % Number of vertices in mesh
idx    = bcon.idx;               % Get indices of boundary conditions
values = bcon.values;            % Get values of the boundary conditions              
free   = setdiff( 1:3*V, idx );  % Get indices of non-boundary conditions

%--- Apply boundary conditions --------------------------------------------
v(idx) = 0;
p(idx) = values;

b      =  btmp(free)  - Atmp(free,idx)*v(idx);
A      =  sparse( Atmp(free,free) );

%--- Do velocity update ---------------------------------------------------
% v(free)    = A \ b;       % Direct method

% Use plain old conjugate gradient method
if profile
  % PCG return values:  X,FLAG,RELRES,ITER,RESVEC
  M = sparse( diag(diag(A)) );
  [v(free), ~, ~, ~, conv] = pcg( A, b, [], [], M);
else
  M = sparse( diag(diag(A)) );
  [v(free) ~] = pcg( A, b, [], [], M);
  conv        = [];
end

%--- Do position update ---------------------------------------------------
p(free)    = p(free) + dt*v(free);

%--- Store the updated values in state structure --------------------------
state.vx = v(1:V);
state.vy = v(V+1:2*V);
state.vz = v(2*V+1:end);
state.x  = p(1:V);
state.y  = p(V+1:2*V);
state.z  = p(2*V+1:end);

end