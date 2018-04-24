function [ V ] = fem_compute_volume(x,mesh)
% Copyright 2011, Kenny Erleben

cntV = length(mesh.x0);
px   =  x(       1:  cntV);
py   =  x(  cntV+1:2*cntV);
pz   =  x(2*cntV+1:3*cntV);

% Get tetrahedron indices
i = mesh.T(:,1);
j = mesh.T(:,2);
k = mesh.T(:,3);
m = mesh.T(:,4);

% Get vertex coordinates 
Pi = [ px(i),  py(i),  pz(i) ]';
Pj = [ px(j),  py(j),  pz(j) ]';
Pk = [ px(k),  py(k),  pz(k) ]';
Pm = [ px(m),  py(m),  pz(m) ]';

% Compute the tetrahedron element volumes.
%
% Using triple scalar product the tetrahedron volumes can be computed as
%
%   V   =  \frac{1}{6}  (P_m - P_i)  \cdot   ( P_j - P_i)  \times  ( P_k - P_i)
%
V = dot( (Pm - Pi) , cross( (Pj - Pi), (Pk - Pi) ) ) ./ 6.0;

end