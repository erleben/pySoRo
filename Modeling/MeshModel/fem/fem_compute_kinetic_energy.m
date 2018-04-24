function [ KE ] = fem_compute_kinetic_energy( state )
% Copyright 2011, Kenny Erleben

v  = [ state.vx; state.vy; state.vz];  % Current spatial velocity
KE = 0.5 * v'*  state.M * v;           % Current kinetic energy

end