function [ ke ] = fem_compute_elastic_force_elements(mesh, state, params)
% Copyright 2011, Kenny Erleben

%--- Get number of elements
cntT = length(mesh.T(:,1));

%--- Allocate space for local elastic force vector
ke = repmat(zeros(3,1),4,cntT);

%--- Get elastic material parameters
E  = params.E;    % Young modulus
nu = params.nu;   % Poisson ratio
%--- Convert E and nu into Lamé coefficients
lambda = (E*nu) / ( (1 + nu)*(1 - 2*nu) );
mu     =  E     / (        2*(1+nu)     );

%--- Now compute local elastic forces
for e=1:cntT

  %--- Pre computation of block indices -- these will be used again and again
  from = (e-1)*3 + 1;
  to   = e*3;
  
  %--- Get tetrahedron indices
  i = mesh.T(e,1);
  j = mesh.T(e,2);
  k = mesh.T(e,3);
  m = mesh.T(e,4);
  
  %--- Get spatial vertex coordinates
  Pei = [ state.x(i);  state.y(i);  state.z(i) ];
  Pej = [ state.x(j);  state.y(j);  state.z(j) ];
  Pek = [ state.x(k);  state.y(k);  state.z(k) ];
  Pem = [ state.x(m);  state.y(m);  state.z(m) ];
  
  %--- Define current spatial edge matrix
  E  = [  Pej-Pei, Pek-Pei, Pem-Pei ];
  
  %--- Compute deformation gradient
  %
  %    E = F * E0
  %
  % note inv(E0) is precomputed
  invE0 = mesh.invE0(:,from:to);
  
  Fe    = E*invE0;                     % The Deformation gradient
  
  % Compute strain measures that we might need later on
  Ce    = Fe'*Fe;                      % Right Cauchy Strain Tensor
  % [V,D] = eig(Ce);                     % Squared principal stretches = squared eigenvalues of C
  Ee    = 0.5.*(Ce - eye(3,3));        % Green Strain Tensor
  
  %--- Compute first Piola--Kirchhoff stress tensor for the element
  %
  % In principle this should be done in a generic fashion so one simply
  % supplies a strain energy funciton (psi). Taking the derivative of psi
  % yields the stress tensor.
  %
  %  Pe =     dpsi_dF;            % Strain energy as function of deformation gradient
  %   
  %  Se = 2.* dpsi_dC;            % Strain energy as function of right Cauchy strain
  %  
  %  Se =     dpsi_dE;            % Strain energy as function of Green strain
  %  
  %  De = 2.* dpsi_dD;            % Strain energy as function of principal stretches
  %  sE =   V*De*V';
  %  
  %  Pe = Fe * Se; 
  %
  % However, for this proof-of-concept implementation so we have hard-wired
  % the material model to that of Staint Venant--Kirchhoff
  %
  % Psie = 0.5 .* lambda .* trace(Ee).^2 + mu .* sum(sum( Ee .* Ee));
  %
  Se = (lambda*trace(Ee)).*eye(3,3) + (2*mu).*Ee;
 
  % Compute first piola kirchhoff stress tensor for the element
  Pe = Fe * Se; 
  
  kei = mesh.V(e) .* Pe * mesh.nabla_Ne(from:to,1);
  kej = mesh.V(e) .* Pe * mesh.nabla_Ne(from:to,2);
  kek = mesh.V(e) .* Pe * mesh.nabla_Ne(from:to,3);
  kem = mesh.V(e) .* Pe * mesh.nabla_Ne(from:to,4);
          
  ke(:, e) =  [kei; kej; kek; kem ];
end

end