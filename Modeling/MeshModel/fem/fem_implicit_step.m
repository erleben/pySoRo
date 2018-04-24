function [ state, conv, flag, iter, message ] = fem_implicit_step(dt, mesh, state, params, bcon, profile, iter_max, abs_tol, rel_tol, dir_tol, stag_tol)
% Copyright 2011, Kenny Erleben

%--- Check if arguments are valid or assing defaults ----------------------
if (nargin < 6)
  error('Not enough input arguments');
end

if(nargin < 7)
  iter_max = 30;
end
if (iter_max <= 0)
  iter_max = 30;
  display( strcat( 'Forcing iter max =', num2str(iter_max) ) );
end

if(nargin < 8)
  abs_tol = 1e-2;
end
if (abs_tol <= 0)
  abs_tol = 1e-2;
  display( strcat( 'Forcing abs. tol =', num2str(abs_tol) ) );
end

if(nargin < 9)
  rel_tol = 1e-5;
end
if (rel_tol <= 0)
  rel_tol = 1e-5;
  display( strcat( 'Forcing rel. tol =', num2str(rel_tol) ) );
end

if(nargin < 10)
  dir_tol = 1e-7;
end
if (dir_tol <= 0)
  dir_tol = 1e-7;
  display( strcat( 'Forcing dir. tol =', num2str(dir_tol) ) );
end

if(nargin < 11)
  stag_tol = eps*100;
end
if (stag_tol <= 0)
  stag_tol = eps*100;
  display( strcat( 'Forcing stag. tol =', num2str(stag_tol) ) );
end

conv            = [];

ITERATING       = 0;
ABSOLUTE        = 1;
RELATIVE        = 2;
STAGNATION      = 3;
NONDESCENT      = 4;
SMALL_DIRECTION = 5;
MAXITER         = 6;
LOCALMIN        = 7;

fx    = state.fx;
fy    = state.fy;
fz    = state.fz;

p0    = [ state.x;  state.y;  state.z];   % Current spatial position
v0    = [ state.vx; state.vy; state.vz];  % Current spatial velocity

x0    = [p0;v0];
x     = x0;

outer_iter     = 1;
max_outer_iter = 1;

%--- Incremental loading --------------------------------------------------
while 1,
  
  if( outer_iter > max_outer_iter)
    break;
  end
  
  load = outer_iter / max_outer_iter;
  
  state.fx = load*fx;
  state.fy = load*fy;
  state.fz = load*fz;
  
  outer_iter = outer_iter + 1;
  
  %--- Make a good prediction for starting iterate ------------------------
  display('Gradient descent method...');
  for i=1:0,
    %  psi       = 1/2 phi^T phi
    %  dpsi      = 1/2 dphi^T phi + 1/2 phi^T dphi = phi^T dphi
    %  dphi      = ad_x phi  dx
    %  dpsi      = phi^T ad_x_phi dx
    %  dpsi      = ad_x_psi dx
    %  ad_x_psi  = phi^T ad_x_phi
    %  nabla_psi =  (ad_x psi)^T  = ad_x_phi^ phi
    %  x         = x - nabla_psi
   b = fem_phi( x,  dt, mesh, state, params, bcon);   
   J = fem_nabla_phi( x,  0, mesh, state, params, bcon);
   nabla_psi = J' * b;
   
   % Do a line search along the gradient descent direction
   % in order to not over step
   psi     = b'*b;
   tau     = 1;
   x0      = x;
   while 1,
     x = x0 - tau*nabla_psi;
     b = fem_phi( x,  dt, mesh, state, params, bcon);
     psi_tau = b'*b;
     if(psi_tau < psi)
       display( strcat('  step length =', num2str(tau) ) );
       display( strcat('  psi =', num2str(psi_tau) ) );
       break;
     end
     tau = tau*0.5;
   end
   
   
  end
  
  %--- Call the Newton method ---------------------------------------------
  display('Newton method...');
  flag  = ITERATING;
  iter  = 1;           % Iteration counter
  psi   = inf;
  while 1,
    
    %--- Test if we exceeded maximum iteration count ----------------------
    if(iter > iter_max)
      message = 'Exceeded max iteration limit';
      iter    = iter_max;
      flag    = MAXITER;
      break
    end
    
    %--- Get value of current iterative -----------------------------------
    phi = fem_phi( x,  dt, mesh, state, params, bcon);
    
    %--- Test for absolute convergence ------------------------------------
    psi_old  = psi;
    psi      = norm(phi,2);
    if( profile )
      conv = [conv; psi];
    end
    if( psi < abs_tol )
      message = 'Absolute convergence';
      flag    = ABSOLUTE;
      break
    end
    
    %--- Test for relative convergence ------------------------------------
    rel_tst = abs(psi_old - psi)/ abs(psi);
    if( rel_tst < rel_tol )
      display( strcat('  Relative convergence =', num2str( rel_tst )) );
      message = 'Relative convergence';
      flag    = RELATIVE;
      break
    end
        
    %--- Compute Jacobian -------------------------------------------------
    nabla_phi = fem_nabla_phi( x,  dt, mesh, state, params, bcon);
    
    %--- Compute Newton Direction -----------------------------------------
    [delta ~] = gmres( nabla_phi, -phi);
    
    %--- Test if we have a sufficient large Newton direction
    delta_norm = norm(delta, inf );
    if( delta_norm < dir_tol )            
      message = 'Newton direction too small -- Im giving up';
      flag    = SMALL_DIRECTION;
      break
    end
        
    %--- Test for local minimum -------------------------------------------
    nabla_psi = 2 * delta' * nabla_phi;
    if( norm(nabla_psi,2) < rel_tol )
      message = 'Local minimum';
      flag    = LOCALMIN;
      break
    end
    
    %--- Test for descent direction ---------------------------------------
    dir_deriv = phi' * nabla_phi * delta;
    if (dir_deriv > 0)
      message = 'Non-descent direction -- Im giving up';
      flag    = NONDESCENT;
      break
    end
    
    %--- Do a line search -------------------------------------------------
    tau     = 1;        % Initial step length value
    beta    = 0.001;    % Sufficient decrease parameter
    alpha   = 0.5;      % Step length reduction parameter
    tau_min = eps*100;  % Minimum allowed step length
    dpsi    = dir_deriv*beta;
    %vol     = fem_compute_volume(x, mesh);
    while 1,
      
      x_tau   = x + delta*tau;
      phi_tau = fem_phi( x_tau,  dt, mesh, state, params, bcon);
      psi_tau = norm(phi_tau,2);
      
      vol_tau = fem_compute_volume(x_tau, mesh);
      min_vol = min(vol_tau(:))>0;
      % ratio   = abs(vol_tau - vol) ./ vol;
      
      if (psi_tau < (psi + dpsi*tau)) && (min_vol > 0), % && (ratio < 0.1),
        display( strcat('  line-search: step length=', num2str(tau)) );
        break;
      end
      
      tau = tau*alpha;
      
      if tau < tau_min,
        display('  line-search: too small step length');
        break;
      end
      
    end
    
    %--- Do a Newton update -----------------------------------------------
    x_old = x;
    x     = x_tau;
    
    %--- Test if we have stagnation ---------------------------------------
    diff = max( norm( x - x_old, inf ) );
    if( diff < stag_tol )
      message = 'Stagnation of updates -- Im giving up';
      flag    = STAGNATION;
      break
    end
    
    iter = iter + 1;
  end
  
  %--- Debug output -------------------------------------------------------
  if( profile )
    display(message)
  end
  
end

%--- Put back the solution into state -------------------------------------
p        = x(1:length(p0));
v        = x(length(p0)+1:end);

cntV     = length(mesh.x0);

state.x  = p(1:cntV);
state.y  = p(cntV+1:2*cntV);
state.z  = p(2*cntV+1:end);

state.vx = v(1:cntV);
state.vy = v(cntV+1:2*cntV);
state.vz = v(2*cntV+1:end);

end