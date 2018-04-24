function [ mesh ] = fem_create_mesh(T, X, Y, Z)
% Copyright 2011, Kenny Erleben

cntT = length(T(:,1));  % Number of tetrahedrons
cntV = length(X);       % Number of vertices

nabla_Ne = repmat(zeros(3,1),cntT,4); % Element matrial gradients
invE0    = repmat(zeros(3,3),1,cntT); % Inverse material edge matrices

x0 = X;                               % Material coordinates
y0 = Y;
z0 = Z;

% Get tetrahedron indices
i = T(:,1);
j = T(:,2);
k = T(:,3);
m = T(:,4);

% Get vertex coordinates 
Pi = [ x0(i),  y0(i),  z0(i) ]';
Pj = [ x0(j),  y0(j),  z0(j) ]';
Pk = [ x0(k),  y0(k),  z0(k) ]';
Pm = [ x0(m),  y0(m),  z0(m) ]';

% Compute the tetrahedron element volumes.
%
% Using triple scalar product the tetrahedron volumes can be computed as
%
%   V   =  \frac{1}{6}  (P_m - P_i)  \cdot   ( P_j - P_i)  \times  ( P_k - P_i)
%
V = dot( (Pm - Pi) , cross( (Pj - Pi), (Pk - Pi) ) ) ./ 6.0;

% Now compute material gradients
for e=1:cntT
    
  % Get material vertex coordinates of e'th element
  Pei = Pi(:,e);
  Pej = Pj(:,e);
  Pek = Pk(:,e);
  Pem = Pm(:,e);
  
  % Compute material gradients of the barycentric coordinates
  %
  %   Using triple scalar product the tetrahedron volumes can be computed as
  %
  %   V   =  \frac{1}{6}  (P_m - P_i)  \cdot   ( P_j - P_i)  \times  ( P_k - P_i)
  %
  %   V_i =  \frac{1}{6}  (P   - P_j)  \cdot   ( P_m - P_j)  \times  ( P_k - P_j)
  %   V_j =  \frac{1}{6}  (P   - P_i)  \cdot   ( P_k - P_i)  \times  ( P_m - P_i)
  %   V_k =  \frac{1}{6}  (P   - P_i)  \cdot   ( P_m - P_i)  \times  ( P_j - P_i)
  %   V_m =  \frac{1}{6}  (P   - P_i)  \cdot   ( P_j - P_i)  \times  ( P_k - P_i)
  %
  %   And the bary centric coordinates are then defined as the weighted volumes
  %
  %   w_i = \frac{V_i}{V}
  %   w_j = \frac{V_j}{V}
  %   w_k = \frac{V_k}{V}
  %   w_m = \frac{V_m}{V}
  %
  nabla_Nei =  cross( Pem - Pej, Pek - Pej ) / (V(e)*6);
  nabla_Nej =  cross( Pek - Pei, Pem - Pei ) / (V(e)*6);
  nabla_Nek =  cross( Pem - Pei, Pej - Pei ) / (V(e)*6);
  nabla_Nem =  cross( Pej - Pei, Pek - Pei ) / (V(e)*6);
  
  from = (e-1)*3 + 1;
  to   = e*3;
  
  nabla_Ne(from:to,:) = [ nabla_Nei, nabla_Nej, nabla_Nek, nabla_Nem];
  
  
  % Create edge matrices
  E0 = [Pej-Pei, Pek-Pei, Pem-Pei ];
  
  invE0(:, from:to) = inv(E0);
end

mesh = struct( 'x0', x0, 'y0', y0, 'z0', z0,...
  'T', T,...
  'V', V,...
  'nabla_Ne', nabla_Ne,...
  'invE0', invE0...
  );

end