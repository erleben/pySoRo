P=load('culturenight_unordered.mat');
P = P.points;

figure;

hold on;
for i = 1:231
    p = P{i}.all;
    scatter3(p(:,1),p(:,2),p(:,3),2);
    %drawnow;
end


figure;
hold on;

p = P{121}.all;
radii = ones(length(p),1)*0.005;
p = [p,radii];

for b = 1:length(p)
    plot(sphereModel(p(b,:)));
end