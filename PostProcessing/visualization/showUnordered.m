
figure;
hold on;
for i = 1:56
    scatter3(points.points{i}.all(:,1),points.points{i}.all(:,2),points.points{i}.all(:,3));
    hold on;
end