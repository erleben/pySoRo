function [bestR, bestT, oldmse, in] = getTransformRansac(points_1, points_2, min_p)

% We know which points are corresponding to one another. We can now find the
% rigid trasformation that minimizes the distance between them.
% We can remove the points that have the worst contribution to the mse.

[numObs, ~] = size(points_1);
oldmse = inf;
in = [];
% All the combinations of points we cant to keep
combos = nchoosek(1:numObs,min_p);
[num_combos, ~] = size(combos);
for rnd = 1:num_combos
    err = zeros(numObs,1 );
    inds = datasample(combos(rnd,:)', min_p, 'Replace', false);
    [R_r, T_r] = getTransformParam(points_1(inds,:), points_2(inds,:));
    
    for i = 1:numObs
        err(i) = err(i) + sqrt(sum((points_2(i,:)-((R_r*points_1(i,:)')'+T_r')).^2));
    end
    
    mse = mean(err(inds));
    if (mse < oldmse) && abs(det(R_r)-1)<(10^-10)
        bestR = R_r;
        bestT = T_r;
        in = inds;
        oldmse = mse;
    end
    
end


end