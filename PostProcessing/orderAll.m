% NB: You have to run runCalibration.m and segmentAll.m before running this
% script.
% The points produced in segmentAll.m are not ordered, such that point n in 
% iteration i does not nercessarly correspond to point n in itaration j. 
% This script reads in the points, orders them, removes noisy data, interpolates missing
% values and stores them i a csv file.
points = load('outputSegment/unordered_points_g2.mat');
points = points.points;
points = points(1:29*35);

num_alphas = size(points,2);
num_pr_round = 29;
num_rounds = num_alphas/num_pr_round;
num_markers = 12;



points  = reshape(points, num_pr_round, num_rounds);
order_to = points{1,1}.all;
ordered = cell(num_pr_round,num_rounds);
ES = cell(num_pr_round, 1);
add_new = true;

for i = 1:num_pr_round
    
%     for j = 1:num_rounds
%         [tracked_all, estimated]= order_markers(order_to, points{i,j}.all, add_new);
%         p={};
%         p.all = tracked_all;
%         p.estimated = estimated;
%         ordered{i,j} = p;
%         order_to = tracked_all;
%     end
% 
%     cleaned = cleanAndInterp(ordered(i,:),num_markers, false);
%     points(i,:)=cleaned;
%     order_to = cleaned{1}; 
     
    for j = 1:num_rounds
        [tracked_all, estimated]= order_markers(order_to, points{i,j}.all, add_new);
        p={};  
        p.all = tracked_all;
        p.estimated = estimated;
        ordered{i,j} = p;
        order_to = tracked_all;
    end
    [cleaned, E] = cleanAndInterp(ordered(i,:),num_markers, true);
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
csvwrite('outputOrder/ordered_grabber_g2.csv',p);
