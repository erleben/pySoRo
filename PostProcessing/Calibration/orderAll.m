points = load('unordered_points.mat');
points = points.points;

num_alphas = 2601;
num_pr_round = 51;
num_rounds = num_alphas/num_pr_round;
num_markers = 19;


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

% figure;
% for k = 1:19
% p = [];
% for i = 1:51
%     for j = 1:51
%         p = [p;ordered{i,j}(k,:)];
%     end
% end
% scatter3(p(:,1),p(:,2),p(:,3))
% hold on;

p = [];
for i = 1:num_pr_round
    for j = 1:num_rounds
        p = [p; reshape(ordered{i,j}',num_markers*3, 1)'];
    end
end

csvwrite('ordered_twoP.csv',p);
