function [ state ] = fem_compute_elastic_forces( mesh, state, params )
% Copyright 2011, Kenny Erleben

ke        = fem_compute_elastic_force_elements(mesh, state, params);
state.k   = fem_assemble_global_vector(mesh, ke);

end