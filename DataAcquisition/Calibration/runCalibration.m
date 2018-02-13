
serial_1 = '618204002727';
serial_2 = '616205005055';


points_1 = getPoints(serial_1);
points_2 = getPoints(serial_2);
[R,T] = getTransformParam(points_1, points_2);

points_2 = circshift(points_2,1);


ref_PC = pcread(strcat('data/',serial_1,'fore.ply'));
target_PC = pcread(strcat('data/',serial_2,'fore.ply'));

mse = 0;
for i = 1:length(points_1)
    mse = mse + sqrt(sum((points_2(i,:)-((R*points_1(i,:)')'+T')).^2));
end
mse=mse/length(points_1);
mse


ref_transformed = zeros(ref_PC.Count,3);
ref_points = ref_PC.Location;
for i = 1:ref_PC.Count
    ref_transformed(i,:)=(R*ref_points(i,:)')'+T';
end

subplot(1,3,1);
pcshow(ref_PC);
view([0 -90])

subplot(1,3,2);
pcshow(target_PC);
view([0 -90])

subplot(1,3,3);
ref_transformed_PC = pointCloud(ref_transformed, 'Color', ref_PC.Color);
pcshow(ref_transformed_PC); 
xlabel('x')
ylabel('y')
title('Result');
view([0 -90])
R
T
det(R)
pcmerged=pcmerge(ref_transformed_PC,target_PC,0.001);

hold on;
figure;
pcshow(pcmerged);
view([0 -90])