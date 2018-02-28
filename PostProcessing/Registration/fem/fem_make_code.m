% Matlab script for generating c-code of tangent stiffness matrix elements
% Copyright 2011, Kenny Erleben, DIKU.
%--- Clean up environment -------------------------------------------------
clear all;
close all;
clc;
reset(symengine)

%--- Declare symbols we are going to use ----------------------------------
syms lambda mu real;
syms F11 F12 F13 F21 F22 F23 F31 F32 F33 real;

F = [F11 F12 F13;...
     F21 F22 F23;...
     F31 F32 F33...
     ];
   
C = (F')*F;
%I_C = trace(C);
%II_C = (1/2)*(I_C^2 - trace(C^2));
%III_C = det(C);
E = (1/2) * (C-eye(3,3));

%--- Strain energy function -----------------------------------------------
psi = (1/2) * lambda* trace(E)^2 + mu * trace(E*E);

%--- First Piola--Kirchhoff stress tensor: P = dpsi/dF --------------------
P = sym('TEMP')*ones(3,3);
for i=1:3
  for j=1:3
    P(i,j) = diff(psi, F(i,j));
  end
end
ccode(P)

%--- Material Elasticity Censor: A = d^2 psi / dF dF ----------------------
A = sym('TEMP')*ones(9,9);
for i=1:3
  for j=1:3
    for k=1:3
      for m=1:3
        r = (i-1)*3 + k;
        c = (j-1)*3 + m;
        A( r, c ) = diff( P(i,j) , F(k,m));
      end
    end
  end
end

A = simplify(A);
ccode(A)
matlabFunction(A,'file','compute_A.m');

%--- tangent stiffness element: Kab(i,k) = sum_{j,m} A(i,j,km)*Nb(m)*Na(j)
syms Ga1 Ga2 Ga3 real;
syms Gb1 Gb2 Gb3 real;

Ga = [Ga1; Ga2; Ga3];
Gb = [Gb1; Gb2; Gb3];

% syms A1111 A1112 A1113 A1211 A1212 A1213 A1311 A1312 A1313 real;
% syms A1121 A1122 A1123 A1221 A1222 A1223 A1321 A1322 A1323 real;
% syms A1131 A1132 A1133 A1231 A1232 A1233 A1331 A1332 A1333 real;
% syms A2111 A2112 A2113 A2211 A2212 A2213 A2311 A2312 A2313 real;
% syms A2121 A2122 A2123 A2221 A2222 A2223 A2321 A2322 A2323 real;
% syms A2131 A2132 A2133 A2231 A2232 A2233 A2331 A2332 A2333 real;
% syms A3111 A3112 A3113 A3211 A3212 A3213 A3311 A3312 A3313 real;
% syms A3121 A3122 A3123 A3221 A3222 A3223 A3321 A3322 A3323 real;
% syms A3131 A3132 A3133 A3231 A3232 A3233 A3331 A3332 A3333 real;
% 
% A = [A1111 A1112 A1113 A1211 A1212 A1213 A1311 A1312 A1313;...
% A1121 A1122 A1123 A1221 A1222 A1223 A1321 A1322 A1323;...
% A1131 A1132 A1133 A1231 A1232 A1233 A1331 A1332 A1333;...
% A2111 A2112 A2113 A2211 A2212 A2213 A2311 A2312 A2313;...
% A2121 A2122 A2123 A2221 A2222 A2223 A2321 A2322 A2323;...
% A2131 A2132 A2133 A2231 A2232 A2233 A2331 A2332 A2333;...
% A3111 A3112 A3113 A3211 A3212 A3213 A3311 A3312 A3313;...
% A3121 A3122 A3123 A3221 A3222 A3223 A3321 A3322 A3323;...
% A3131 A3132 A3133 A3231 A3232 A3233 A3331 A3332 A3333];

%  syms A11 A12 A13 A14 A15 A16 A17 A18 A19 real;
%  syms A21 A22 A23 A24 A25 A26 A27 A28 A29 real;
%  syms A31 A32 A33 A34 A35 A36 A37 A38 A39 real;
%  syms A41 A42 A43 A44 A45 A46 A47 A48 A49 real;
%  syms A51 A52 A53 A54 A55 A56 A57 A58 A59 real;
%  syms A61 A62 A63 A64 A65 A66 A67 A68 A69 real;
%  syms A71 A72 A73 A74 A75 A76 A77 A78 A79 real;
%  syms A81 A82 A83 A84 A85 A86 A87 A88 A89 real;
%  syms A91 A92 A93 A94 A95 A96 A97 A98 A99 real;
%  
%  A = [A11 A12 A13 A14 A15 A16 A17 A18 A19;...
%  A21 A22 A23 A24 A25 A26 A27 A28 A29;...
%  A31 A32 A33 A34 A35 A36 A37 A38 A39;...
%  A41 A42 A43 A44 A45 A46 A47 A48 A49;...
%  A51 A52 A53 A54 A55 A56 A57 A58 A59;...
%  A61 A62 A63 A64 A65 A66 A67 A68 A69;...
%  A71 A72 A73 A74 A75 A76 A77 A78 A79;...
%  A81 A82 A83 A84 A85 A86 A87 A88 A89;...
%  A91 A92 A93 A94 A95 A96 A97 A98 A99];

Kab = sym('TEMP')*ones(3,3);
Kab(:,:) = 0;
for i=1:3
  for k=1:3
    
    for j=1:3
      for m=1:3
        % A(r,c) = A(i,j,k,m)
        r = (i-1)*3 + k;
        c = (j-1)*3 + m;
        Kab( i, k ) = Kab( i, k ) + A(r,c)*Gb(m)*Ga(j);
      end
    end
    
  end
end
Kab = simplify(Kab);
ccode(Kab)
matlabFunction(Kab,'file','compute_K.m');
%--------------------------------------------------------------------------
