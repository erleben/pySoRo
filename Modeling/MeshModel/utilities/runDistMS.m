grid = load('distMSgrid');
distMS = load('distMS');
distMS = distMS.distMS;
min_len = 0.02;

% xs = interp(double(grid.xs),2);
% ys = interp(double(grid.ys),2);
% zs = interp(double(grid.zs),2);
% B = interp3(distMS,2);
 
fn = @(p) distFunction(p, B, xs, ys, zs);
distmeshnd(fn,@huniform, min_len,[min(xs),min(ys),min(zs);max(xs),max(ys),max(zs)]*1,[]);