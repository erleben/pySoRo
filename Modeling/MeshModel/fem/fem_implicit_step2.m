function [ state, conv ] = fem_implicit_step2(dt, mesh, state, params, bcon, ~)
% Copyright 2011, Kenny Erleben

conv = []; % Convergence rate monitoring is not supported for this stepper, so we just return an empty array.

options = optimset('Jacobian','on','Display','iter', 'TolFun', 10e-2, 'TolX', 10e-5 );


V  = length( state.x );                % Number of vertices
p0 = [ state.x; state.y; state.z];     % Current spatial position
v0 = [ state.vx; state.vy; state.vz];  % Current spatial velocity

fx = state.fx;
fy = state.fy;
fz = state.fz;

p0 = p0 + dt*v0;
x0 = [ p0; v0 ];
x  = x0;

state.fx = zeros(size(fx));
state.fy = zeros(size(fy));
state.fz = zeros(size(fz));

iter = 1;
iter_max = 20;

while iter<=iter_max

  load = iter ./ iter_max;
  
  state.fx = load.*fx;
  state.fy = load.*fy;
  state.fz = load.*fz;
  
  f  = @(x)  myfun( x, dt, mesh, state, params, bcon);
  x  = fsolve( f, x, options);
  
  iter = iter + 1;

end

p = x(1:length(p0));
v = x(length(p0)+1:end);

state.x  = p(1:V);
state.y  = p(V+1:2*V);
state.z  = p(2*V+1:end);
state.vx = v(1:V);
state.vy = v(V+1:2*V);
state.vz = v(2*V+1:end);

end


function [y J] = myfun( x, dt, mesh, state, params, bcon)
y = fem_phi( x, dt, mesh, state, params, bcon);
J = fem_nabla_phi( x, dt, mesh, state, params, bcon);
end