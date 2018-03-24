kit = load('kit.mat');
kit = kit.kit;

from = 0;
to = 7;
for i = from:to
    a1 = -i*1000;
    for j = from:to
        a2 = -j*1000;
        
        X = kit.X0 + kit.JK'*[a1;a2;a1^2;a1*a2;a2^2];
        X = reshape(X,length(X)/3,3);
        tetramesh(kit.T,[X(:,1), X(:,2), X(:,3)]);
        drawnow;
    end
end