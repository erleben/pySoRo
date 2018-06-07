% NB: You have to run runCalibration.m and segmentAll.m before running this
% script.
% The points produced in segmentAll.m are not ordered, such that point n in 
% iteration i does not nercessarly correspond to point n in itaration j. 
% This script reads in the points, orders them, removes noisy data, interpolates missing
% values and stores them i a csv file.

points = load('outputSegment/unordered_points_grabber.mat');
points = points.points;
points = points(1:29*35);

num_alphas = size(points,2);
num_pr_round = 29;
num_rounds = num_alphas/num_pr_round;
num_markers = 10;


order_to = {};
points  = reshape(points, num_pr_round, num_rounds);
order_to.all = points{1,1}.all;
order_to.estimated = [];
ordered = cell(num_pr_round,num_rounds);
add_new = true;
for i = 1:num_pr_round
    for j = 1:num_rounds
        [tracked_all, estimated]= order_markers(order_to.all, points{i,j}.all, add_new);
        p={};
        p.all = tracked_all;
        p.estimated = estimated;
        ordered{i,j} = p;
        order_to.all = tracked_all;
    end
    cleaned = cleanAndInterp(ordered(i,:),num_markers);
    ordered(i,:)=cleaned;
    order_to.all = cleaned{1};
    add_new = false;
    
end 


p = [];
for i = 1:num_pr_round
    for j = 1:num_rounds
        p = [p; reshape(ordered{i,j}',num_markers*3, 1)'];
    end
end

csvwrite('outputOrder/ordered_grabber.csv',p);
