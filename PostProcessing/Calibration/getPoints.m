function [points, sphere_pcs] = getPoints(serial, directory)

back_name = strcat(directory,serial,'color_back.tif');
fore_name = strcat(directory,serial,'color_fore.tif');

balls = getBallProps(back_name,fore_name);

pc = pcread(strcat(directory,serial,'fore.ply'));
tex_name = strcat(directory,serial, 'texture_fore.tif');
[spheremodels, sphere_pcs]=getSpheres(balls, pc, tex_name, true);

numBalls = length(spheremodels);
points = zeros(numBalls,3);
for num = 1:numBalls
    points(num,:)=spheremodels{num}.Center;
end

end