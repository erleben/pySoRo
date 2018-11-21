% NB: You have to run runCalibration.m and segmentAll.m before running this
% script.
% The points produced in segmentAll.m are not ordered, such that point n in 
% iteration i does not nercessarly correspond to point n in itaration j. 
% This script reads in the points, orders them, removes noisy data, interpolates missing
% values and stores them i a csv file.
points = load('outputSegment/finger_nuc_1.mat');
points = points.points;
points = points(1:8*7);

num_alphas = size(points,2);
num_pr_round = 8;
num_rounds = num_alphas/num_pr_round;
num_markers = 3;



points  = reshape(points, num_pr_round, num_rounds);
order_to = points{1,1}.all;
ordered = cell(num_pr_round,num_rounds);
ES = cell(num_pr_round, 1);
add_new = true;

for i = 1:num_pr_round

    for j = 1:num_rounds

        [tracked_all, estimated]= order_markers(order_to, points{i,j}.all, add_new);

        p={};  
        p.all = tracked_all;
        p.estimated = estimated;
        ordered{i,j} = p;
        order_to = tracked_all;
    end
    [cleaned, E] = cleanAndInterp(ordered(i,:),num_markers);
    ES{i} = E;
    ordered(i,:)=cleaned;
    order_to = cleaned{1};
    add_new = false;
    
end   


p = [];
e = [];
for i = 1:num_pr_round
    for j = 1:num_rounds
        p = [p; reshape(ordered{i,j}',num_markers*3, 1)'];
        e = [e; ES{i}(j,:)];
    end
end
frac_e = sum(sum(e))/numel(e)


imagesc(e);
xlabel('marker');
ylabel('configuration');
hold on;
scatter(700,16,'f','y','visible','on');
scatter(500,10,'f','b','visible','on');
legend('interpolated','not imterpolated');



figure;
perc = (sum(e))/size(e,1)*100;
plot(perc,'ob')
xlabel('marker');
ylabel('interpolation frequency, %');
hold on;
fill([0,20,20,0],[20,20,0,0],'g');
fill([0,20,20,0],[40,40,100,100],'r');
alpha 0.1
legend('interpolation frequency of marker', '<20%', '>40%')

csvwrite('outputOrder/ordered_nuc_finger.csv',p(:,repelem(perc,3)<20));