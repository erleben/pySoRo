% Path finding for soft robot
% phantom_model: IK model of end effector
% conf: current confgration
% goal_pos: goal position of end effector
% goal_conf

% robot_model: IK model of physical parts of the robot
% obstacle: sphere representing an obstacle

% GOAL: Find a path in the configuration space, from conf to goal_conf,
% such that the parts that are modeled by robot_model never collides with
% the obstacles

% Approach: Sample the configuration space. Remove configurations for which
% the robot collides with the obstacle
% Find shortest path between conf and goal_conf via sampled points

function a_0 = path_finding(a_0, s_goal)

addpath('../../utilities/');
Alphas  = csvread(strcat('alphamap_grabber.csv'));
P=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2_1.csv');
R=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2_2.csv');

num_samples = 1000;
connectivity = 30;
num_obs = 1;


a_0 = [0,0];
s_goal = P(end,:);

[p_model, pf_model] = k_model(P, Alphas, 1, 4, false, true);
[~, rf_model] = k_model(R, Alphas, 1, 4, false, true);

a_goal = p_model(s_goal');
s_start = pf_model(a_0);

%obstacle_c = median(P);

obstacle_c = zeros(num_obs, 3);
obstacle_r = zeros(num_obs, 1);

for i = 1:num_obs
obstacle_c(i,:) = P(round(rand*length(P)),:);
obstacle_r(i) = 0.027;
end


sample=round(rand(num_samples, 2).*(max(Alphas)-min(Alphas))+min(Alphas));
sample = [a_0; a_goal; sample];

SSR = rf_model(sample);
SSP = pf_model(sample);
num_p = size(SSR,2)/3;

no_collision = true(num_samples+2,1);
for o = 1:num_obs
for i = 1:num_p
    no_collision =no_collision.*logical(sqrt(sum((SSR(:,3*i-2:3*i)-obstacle_c(o,:)).^2,2))>obstacle_r(o));
end
end
no_collision(1:2) = true;
no_collision = logical(no_collision);

SSR = SSR(no_collision,:);
SSP = SSP(no_collision,:);
sample = sample(no_collision,:);

% Create a weighted graph where each node is a configration. Connected to
% the closest configurations. The weight is the distance between them.
dist_mat = pdist2(sample,sample);
[~, di] = mink(dist_mat, connectivity);
for i = 1:size(dist_mat,1)
    dist_mat(i, di(:,i)) = -dist_mat(i,di(:,i));
end
dist_mat(dist_mat>0) = 0;
dist_mat = -dist_mat;

G=digraph(dist_mat);
path = shortestpath(G,1,2);
conf_path = sample(path,:);
plot(conf_path(:,1),conf_path(:,2));
hold on;
scatter(sample(:,1),sample(:,2));

%plot(G)

figure
hold on
for o = 1:num_obs
    plot(sphereModel([obstacle_c(o,:),obstacle_r(o)]));
end
scatter3(s_goal(:,1),s_goal(:,2),s_goal(:,3));
scatter3(s_start(:,1),s_start(:,2),s_start(:,3));
s_path = SSR(path,:);
scatter3(s_path(:,1),s_path(:,2),s_path(:,3));
scatter3(s_path(:,4),s_path(:,5),s_path(:,6));
plot3(s_path(:,1),s_path(:,2),s_path(:,3));
plot3(s_path(:,4),s_path(:,5),s_path(:,6));


sp_path = SSP(path,:);
scatter3(sp_path(:,1),sp_path(:,2),sp_path(:,3));
plot3(sp_path(:,1),sp_path(:,2),sp_path(:,3));

end
