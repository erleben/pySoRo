function points = getPoints(serial)

back_name = strcat('data/',serial,'color_back.tif');
fore_name = strcat('data/',serial,'color_fore.tif');

balls = getBallProps(back_name,fore_name);

pc = pcread(strcat('data/',serial,'fore.ply'));
tex_name = strcat('data/',serial, 'texture_fore.tif');
spheremodels=getSpheres(balls, pc, tex_name, true);

numBalls = length(spheremodels);
points = zeros(numBalls,3);
for num = 1:numBalls
    points(num,:)=spheremodels{num}.Center;
end

end 