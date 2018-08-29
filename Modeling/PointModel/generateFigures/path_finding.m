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
% the robot collides with the obstacle. Resample, such that the density of
% samples is smaller far away from the obstacles.
% Find shortest path between conf and goal_conf via sampled points

function path = path_finding(num_samples, connectivity, penalty, importSam)

addpath('../../utilities/');
Alphas = csvread('data_files/alphamap_grabber.csv');
P=csvread('data_files/ordered_grabber_g2_1.csv');
R=csvread('data_files/ordered_grabber_g2.csv');

if nargin < 1
    num_samples = 1000;
end

if nargin < 2
    connectivity = 30;
end

if nargin < 3
    penalty = 5000; % Penalty for coming close to colliding configuration
end

if nargin < 4
    importSam = false;
end

num_obs = 1;

a_0 = [0,0];
s_goal = [-0.1406,0.0012, 0.5487];


[p_model, pf_model] = k_model(P, Alphas, 1, 8, false, true);
[~, rf_model] = k_model(R, Alphas, 1, 4, false, true);

a_goal = p_model(s_goal);
s_start = pf_model(a_0);

obstacle_c = zeros(num_obs, 3);
obstacle_r = zeros(num_obs, 1);

for i = 1:num_obs
    obstacle_c(i,:) = s_goal; 
    obstacle_r(i) = 0.027;
end

% Sample configuration space and find colliding configurations
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

COL = sample(~no_collision,:);
sam = sample;
coll = ~no_collision;


% Penalize configurations that are close to collision
pun=penalty./min(pdist2(sample,COL),[],2);

to_remove = pun;
pun = 1./pun;
pun = pun/max(pun);
pun = pun*0.7;
pun = pun +0.3;

% Sample more frequently close to collision space
if importSam
    for i  =1:length(to_remove)
        to_remove(i) = binornd(1,pun(i));
    end
else
    to_remove = zeros(size(to_remove));
end
to_keep = logical(~logical(to_remove).*logical(no_collision));
to_keep(1:2)=true;
sample = sample(to_keep,:);
no_collision = no_collision(to_keep,:);
SSP = SSP(to_keep,:);
SSR = SSR(to_keep,:);
pun=penalty./min(pdist2(sample,COL),[],2);

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

W = G.Edges.Weight;
Nodes = G.Edges.EndNodes;

for n = 1:G.numnodes
    W(Nodes(:,2)==n) = W(Nodes(:,2)==n) + pun(n);
end
G.Edges.Weight = W;

path = shortestpath(G,1,2);

no_col_sample =sample(no_collision,:);
col_sample = sam(coll,:);

conf_path = sample(path,:);


% Plot path
figure;
plot(conf_path(:,1),conf_path(:,2),'k','LineWidth',3);
hold on;

scatter(no_col_sample(:,1),no_col_sample(:,2),15,'f','k');
scatter(col_sample(:,1),col_sample(:,2),15,'f','c');
scatter(a_0(1),a_0(2),60,'r','f');
scatter(a_goal(1),a_goal(2),60,'g','f');

legend('Path Chosen','Sampled Configurations', 'Collision Configurations', 'Start Configuration', 'Goal Configuration');
xlabel('\alpha_1')
ylabel('\alpha_2')

figure
hold on
for o = 1:num_obs
    hc = plot(sphereModel([obstacle_c(o,:),obstacle_r(o)]));
    set(hc,'FaceColor','w')
end
scatter3(s_goal(:,1),s_goal(:,2),s_goal(:,3),2,'r','f');
scatter3(s_start(:,1),s_start(:,2),s_start(:,3),2,'r','f');
s_path = SSR(path,:);
for m = 1:num_p
    scatter3(s_path(:,3*m-2),s_path(:,3*m-1),s_path(:,3*m),4,'r','f');
    plot3(s_path(:,3*m-2),s_path(:,3*m-1),s_path(:,3*m),'Color','r','LineWidth',2);
    
end

sp_path = SSP(path,:);
scatter3(sp_path(:,1),sp_path(:,2),sp_path(:,3),4,'b','y');
plot3(sp_path(:,1),sp_path(:,2),sp_path(:,3),'Color','y','LineWidth',2);

p = pcread('../../../PostProcessing/visualization/pc1.ply');
pcshow(p);
set(gca,'color','k');
end
