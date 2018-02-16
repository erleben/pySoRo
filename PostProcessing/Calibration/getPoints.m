function [points, sphere_pcs] = getPoints(serial, directory)

back_name = strcat(directory,serial,'color_back.tif');
fore_name = strcat(directory,serial,'color_fore.tif');

pc = pcread(strcat(directory,serial,'fore.ply'));
tex_name = strcat(directory,serial, 'texture_fore.tif');

balls = getSegments(back_name,fore_name);

sphere_pcs = getObjPointclouds(balls, pc, tex_name);

sphere_models = getSphereModels(sphere_pcs, pc, true);

numBalls = length(sphere_models);
points = zeros(numBalls,3);
for num = 1:numBalls
    points(num,:)=sphere_models{num}.Center;
end

end