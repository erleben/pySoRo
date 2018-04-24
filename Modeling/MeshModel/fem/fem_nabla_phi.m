function [ J ] = fem_nabla_phi( x,  dt, mesh, state, params, bcon)

%--- Get information about boundary conditions ----------------------------
V      = length( state.x );         % Number of vertices
active = bcon.idx;                  % Get indices of boundary conditions
values = bcon.values;               % Get values of the boundary conditions
free   = setdiff( 1:3*V, active );  % Get indices of non-boundary conditions

%--- Assemble all vector and matrices needed ------------------------------
p = x(1:3*V);
v = x(3*V+1:end);
M = state.M;
C = state.C;

%--- Apply boundary conditions --------------------------------------------
v(active) = 0;
p(active) = values;

%--- Partioning of system -------------------------------------------------
Mff = M(free,free);
Cff = C(free,free);
Iff = eye(size(Mff));

%--- Compute tangent stiffness matrix -------------------------------------
tmp    = state;
tmp.x  = p(1:V);
tmp.y  = p(V+1:2*V);
tmp.z  = p(2*V+1:end);
tmp.vx = v(1:V);
tmp.vy = v(V+1:2*V);
tmp.vz = v(2*V+1:end);
Ke     = fem_compute_stiffness_elements(mesh, tmp, params);
K      = fem_assemble_global_matrix( mesh, Ke );
Kff    = K(free,free);

%--- Assemble Jacobian ----------------------------------------------------
%Jff = [ Iff, - dt*Iff; dt*Kff, (Mff + dt*Cff)];
Jpp = eye(size(M));
Jpv = zeros(size(M));
Jvp = zeros(size(M));
Jvv = eye(size(M));

Jpp(free,free) = Iff;        Jpv(free,free) = -dt*Iff;
Jvp(free,free) = dt*Kff;     Jvv(free,free) = (Mff + dt*Cff);

J = [Jpp, Jpv; Jvp, Jvv];

end