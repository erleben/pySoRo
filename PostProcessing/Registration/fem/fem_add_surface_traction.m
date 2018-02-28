function [ state ] = fem_add_surface_traction( state, traction_info )
% Copyright 2011, Kenny Erleben

%--- Get triangle and traction info ---------------------------------------
F    = traction_info.F;
if isempty(F)
  return
end

tx   = traction_info.tx;
ty   = traction_info.ty;
tz   = traction_info.tz;
x    = state.x;
y    = state.y;
z    = state.z;

%--- Get triangle indices -------------------------------------------------
i = F(:,1);
j = F(:,2);
k = F(:,3);

%--- Get vertex coordinates -----------------------------------------------
Pi = [ x(i), y(i), z(i) ]';
Pj = [ x(j), y(j), z(j) ]';
Pk = [ x(k), y(k), z(k) ]';

%--- Compute face areas ---------------------------------------------------
Avec =  cross( (Pj - Pi), (Pk - Pi) )  ./ 2.0 ;
A    =  sum( Avec.*Avec, 1).^(0.5);

%--- Solving integral of products of shape functions for isoparametric ----
%--- linear triangle element ----------------------------------------------
%
%    syms x y real
%    Ni = 1 - x - y
%    Nj = y
%    Nk = x
%    N = [Ni Nj Nk]
%    A = N'* N
%    AA = int(A,x,0,1-y)
%    L = int(AA,y,0,1)
%
% We find the load (nodal traction distribution)  matrix
%
%  L = 1 / 24  *  [ 2*I_3x3    I_3x3   I_3x3;
%                      I_3x3  2*I_3x3   I_3x3;
%                      I_3x3    I_3x3 2*I_3x3; ]
%
L = (eye(9,9) + repmat( eye(3,3), 3, 3)) / 24.0;

%--- The spatial load force -----------------------------------------------
%
%     lf(f) = A(f) * L * [Ti; Tj; Tk]
%
%  where T is the nodal surface traction.
for f=1:length(F(:,1))
  
  i = F(f,1);
  j = F(f,2);
  k = F(f,3);
  
  Ti = [ tx(i); ty(i); tz(i) ];
  Tj = [ tx(j); ty(j); tz(j) ];
  Tk = [ tx(k); ty(k); tz(k) ];
  
  T = [ Ti; Tj; Tk ];
  
  LF = L * T .* A(f);
  
  state.fx(i) = state.fx(i) + LF(1);
  state.fy(i) = state.fy(i) + LF(2);
  state.fz(i) = state.fz(i) + LF(3);
  
  state.fx(j) = state.fx(j) + LF(4);
  state.fy(j) = state.fy(j) + LF(5);
  state.fz(j) = state.fz(j) + LF(6);
  
  state.fx(k) = state.fx(k) + LF(7);
  state.fy(k) = state.fy(k) + LF(8);
  state.fz(k) = state.fz(k) + LF(9);
  
end

end