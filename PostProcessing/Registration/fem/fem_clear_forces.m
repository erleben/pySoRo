function [ state ] = fem_clear_forces( state )
% Copyright 2011, Kenny Erleben

state.fx         = zeros(size(state.fx));
state.fy         = zeros(size(state.fy));
state.fz         = zeros(size(state.fz));

end