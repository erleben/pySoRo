

figure;
P = load('../outputOrder/ordered_grabber_g2.csv');
hold on;
pc = pcread('pc1.ply');
pcshow(pc);
r = 1:1015
for i = [11,12]
scatter3(P(r,i*3-2),P(r,i*3-1),P(r,i*3),10,'f');
end

6