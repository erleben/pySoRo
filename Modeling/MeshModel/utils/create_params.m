function [ params ] = create_params( material, integration, h_max, use_lumped, warp, T )
% Copyright 2011, Kenny Erleben

if (nargin < 1 || isempty(material) )
  material = 'none';
end

switch lower(material)
  case 'cartilage'
    E   = 0.69e6;
    nu  = 0.018;
    rho = 1000;
  case 'cortical bone'
    E   = 16.16e9;
    nu  = 0.33;
    rho = 1600;
  case 'cancellous bone'
    E   = 452e6;
    nu  = 0.3;
    rho = 1600;
  case 'rubber'
    E   = 0.01e9;
    nu  = 0.48;
    rho = 1050;
  case 'concrete'
    E   = 30e9;
    nu  = 0.20;
    rho = 2320;
  case 'copper'
    E   = 125e9;
    nu  = 0.35;
    rho = 8900;
  case 'steel'
    E  = 210e9;
    nu  = 0.31;
    rho = 7800;
  case 'aluminium'
    E   = 72e9;
    nu  = 0.34;
    rho = 2700;
  case 'glass'
    E   = 50e9;
    nu  = 0.18;
    rho = 2190;
  otherwise
    E   = 10e5;    % Young modulus
    nu  = 0.3;     % Poisson ratio
    rho = 1000;
end

c              = 0.0004;  % Steel like viscous damping coefficient (?)
alpha          = 0.2;     % mass damping coefficient, used for Rayleigh type damping
beta           = 0.0;     % stiffness damping coefficient, used for Rayleigh type damping


if (nargin < 2 || isempty(integration) )
  integration    = 'fixed'; % String value that hints at the type of integration to be used.
  %integration    = 'adaptive';
  %integration    = 'implicit';
end

if (nargin < 3 || isempty(h_max) )
  %--- Determine  the largest integration step that is allowed --------------
  switch lower(integration)
    case 'fixed'
      h_max          = 0.001;
    case 'adaptive'
      h_max          = 0.001;
    case 'implicit'
      h_max          = 0.01;
    otherwise
      h_max          = 0.001;
  end
end
h_max = max(eps*10, h_max);  % Make sure h_max always is a positive number larger than machine precision


if (nargin < 4 || isempty(use_lumped) )
  use_lumped = false; % Flag for using lumped mass/damping matrices
end

if (nargin < 5 || isempty(warp) )
  warp = true; % Boolean flag indicating whether stiffness warping is turned on or off.
end

if (nargin < 6 || isempty(T) )
  T = 1.0; % The total simulated time
end
T = max(h_max, T);  % Make sure that we at least simulate one step

%--------------------------------------------------------------------------
fps            = 30;      % The time inbetween two consecutive frames
tol            = 10e-5;   % Adaptive step size tolerance parameter.
k_max          = 4;       % Maximum number of time steps to take before trying to increase time step size.

params = struct( 'c', c,...
  'alpha', alpha, 'beta', beta,...
  'E', E, 'nu', nu,...
  'rho', rho,...
  'h_max', h_max,...
  'fps', fps,...
  'T', T,...
  'tol', tol,...
  'k_max', k_max,...
  'use_lumped', use_lumped,...
  'warp', warp,...
  'integration', integration...
  );

end