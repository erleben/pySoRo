function [bestR, bestT, oldmse, in] = getTrainsformParam_Ransac(points_1, points_2, min_p)

[numObs, ~] = size(points_1);
oldmse = inf;
in = [];
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
    
    if (mse < oldmse) && (det(R_r) == 1)
        bestR = R_r;
        bestT = T_r;
        mse = mean(err(inds));
        in = inds;
        oldmse = mse;
    end
   
end


end