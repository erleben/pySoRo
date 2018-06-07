

figure;
hold on;
pcshow(pc);
for i = [7,9]
scatter3(P(:,i*3-2),P(:,i*3-1),P(:,i*3),10,'f');
end

