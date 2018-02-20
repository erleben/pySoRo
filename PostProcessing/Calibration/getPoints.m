function [points, sphere_pcs] = getPoints(serial, directory, radius)

back_name = strcat(directory,serial, 'color_back.tif');
fore_name = strcat(directory,serial, 'color_fore.tif');

pc = pcread(strcat(directory,serial, 'fore.ply'));
tex_name = strcat(directory,serial, 'texture_fore.tif');

balls = getSegments(back_name, fore_name);

sphere_pcs = getObjPointclouds(balls, pc, tex_name);

if isnan(radius)
    sphere_models = getSphereModels(sphere_pcs, pc, true);
else
    sphere_models = getSphereModelsRadius(sphere_pcs, pc, true, radius);
end

numBalls = length(sphere_models);
points = zeros(numBalls,3);
for num = 1:numBalls
    points(num,:)=sphere_models{num}.Center;
end

end