function [ y ] = fem_phi( x,  dt, mesh, state, params, bcon)
% Copyright 2011, Kenny Erleben

%--- Get information about boundary conditions ----------------------------
V      = length( state.x );         % Number of vertices
active = bcon.idx;                  % Get indices of boundary conditions
values = bcon.values;               % Get values of the boundary conditions
free   = setdiff( 1:3*V, active );  % Get indices of non-boundary conditions

%--- Assemble all vector and matrices needed ------------------------------
F  = [ state.fx; state.fy; state.fz];  % External forces
p0 = [ state.x; state.y; state.z];     % Current spatial position
v0 = [ state.vx; state.vy; state.vz];  % Current spatial velocity
M  = state.M;
C  = state.C;
p  = x(1:length(p0));
v  = x(length(p0)+1:end);

%--- Apply boundary conditions --------------------------------------------
v(active) = 0;
p(active) = values;

%--- Partioning of system -------------------------------------------------
Mff = M(free,free);
Cff = C(free,free);
vf  = v(free);
pf  = p(free);
v0f = v0(free);
p0f = p0(free);
Ff  = F(free);

%--- Compute the elastic forces -----------------------------------------
tmp    = state;
tmp.x  = p(1:V);
tmp.y  = p(V+1:2*V);
tmp.z  = p(2*V+1:end);
tmp.vx = v(1:V);
tmp.vy = v(V+1:2*V);
tmp.vz = v(2*V+1:end);

ke = fem_compute_elastic_force_elements(mesh, tmp, params);
k  = fem_assemble_global_vector(mesh, ke);
kf = k(free);

%--- Evaluate implicit function value -----------------------------------
phi_p       = zeros(size(p));
phi_p(free) = pf - p0f - dt*vf;
phi_v       = zeros(size(v));
phi_v(free) = (Mff + dt*Cff)*vf - Mff*v0f - dt*Ff + dt*kf;

y = [phi_p; phi_v];
end