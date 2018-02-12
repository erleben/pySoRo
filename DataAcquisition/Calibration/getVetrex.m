function depth = getVetrex(X, pc)

Loc = pc.Location;

Loc = Loc(:,1:2);
[M,N]= size(Loc);
Loc = Loc - ones(M,N).*X;

dist = Loc(:,1).^2+Loc(:,2).^2;
[i,ind] = min(dist);
depth = pc.Location(ind,3);
end