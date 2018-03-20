function [mdist, varper] = findModes(k)

points = csvread('datapoints.csv');

[mn, U, varper] = PCA(points,k);
    
projected = (points-mn)*U;


% Find the mean squared error of the packprojection
back_projected = (projected * U') + mn;
diff = points-back_projected;

err = 0;
for p = 1:3:size(points,2)-2
    err = err +sum(sqrt(sum(diff(:,p:p+2).^2,2)));
end
 
mdist = err / numel(points)/3;

end