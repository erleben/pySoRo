function [ Ce ] = fem_compute_rayleigh_damping_elements( Me, Ke, params )
% Copyright 2011, Kenny Erleben

% Rayleigh Damping as an alternative to viscous damping.
Ce = (params.alpha * Me) + (params.beta * Ke);

end