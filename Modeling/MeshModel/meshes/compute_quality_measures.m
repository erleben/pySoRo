function [ Qrr, Qrl, Qtheta, Qvl ] = compute_quality_measures(T, X, Y, Z)
% Copyright 2011, Kenny Erleben

K       = length(T);
Qrr     = zeros(K,1);
Qrl     = zeros(K,1);
Qtheta  = zeros(K,1);
Qvl     = zeros(K,1);

TR = TriRep(T, X, Y, Z);
[~, Rout] = circumcenters(TR);
[~, Rin] = incenters(TR);

for e=1:K
  
  i = T(e,1);  j = T(e,2); k = T(e,3); m = T(e,4);
  
  Pi = [ X(i);  Y(i);  Z(i) ];
  Pj = [ X(j);  Y(j);  Z(j) ];
  Pk = [ X(k);  Y(k);  Z(k) ];
  Pm = [ X(m);  Y(m);  Z(m) ];
  
  V = dot( (Pm - Pi) , cross( (Pj - Pi), (Pk - Pi) ) ) ./ 6.0;
  
  Eij = Pi - Pj;
  Eik = Pi - Pk;
  Eim = Pi - Pm;
  Ejk = Pj - Pk;
  Ejm = Pj - Pm;
  Ekm = Pk - Pm;
  
  Lij = norm(Eij);
  Lik = norm(Eik);
  Lim = norm(Eim);
  Ljk = norm(Ejk);
  Ljm = norm(Ejm);
  Lkm = norm(Ekm);
  
  L_max = max( [Lij, Lik, Lim, Ljk, Ljm, Lkm] );
  L2 = Lij^2 + Lik^2 + Lim^2 + Ljk^2 + Ljm^2 + Lkm^2;
  Lrms =   sqrt( L2/ 6 ); 
  
  Ai =  norm( cross( Ejk, Ekm  ) ) / 2;
  Aj =  norm( cross( Eik, Ekm  ) ) / 2;
  Ak =  norm( cross( Eij, Eim  ) ) / 2;
  Am =  norm( cross( Ejk, Eik  ) ) / 2;
  
  Sij = Lij/(Ak*Am);
  Sik = Lik/(Aj*Am);
  Sim = Lim/(Aj*Ak);
  Sjk = Ljk/(Ai*Am);
  Sjm = Ljm/(Ai*Ak);
  Skm = Lkm/(Ai*Aj);
  S_min = min( [Sij, Sik, Sim, Sjk, Sjm, Skm] );
  
  Qvl(e)    = 12 * (3*V)^(2/3) / L2;    % Barry Joe style
  %Qvl(e)    = 6*sqrt(2)*V/(Lrms^3);    % Klinger/Shewchuck version
  Qrl(e)    = 2 * sqrt(6) * Rin(e) / L_max;
  Qrr(e)    = 3*Rin(e)/Rout(e);
  Qtheta(e) = (9 * sqrt(2)/8) * V * S_min;
  
end

end