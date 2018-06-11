

figure;
P = load('../outputOrder/ordered_grabber_g2.csv');
hold on;
pc = pcread('pc1.ply');
pcshow(pc);

e = logical(e);
r = 1:1015;
for i = 1
est = r(e(r,i));
nest = r(~e(r,i));
%scatter3(P(est,i*3-2),P(est,i*3-1),P(est,i*3),10,'f');
%scatter3(P(nest,i*3-2),P(nest,i*3-1),P(nest,i*3),10,'f');
scatter3(P(:,i*3-2),P(:,i*3-1),P(:,i*3),10,'f');

legend
end

