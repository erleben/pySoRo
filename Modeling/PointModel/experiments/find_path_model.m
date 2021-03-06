% This function creates and stores another functions that takes:
% a - the current configration
% s - the desired shape
% oc, or - the center and radius of the obstacle
% p_model - IK model for the phantom marker
% rf_model - Forward model for the physical robot
% A - Sample of the configration space

function model = find_path_model()

addpath('..');
Alphas  = csvread(strcat('alphamap_grabber.csv'));
P=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2_1.csv');
R=csvread('../../../PostProcessing/outputOrder/ordered_grabber_g2.csv');
A = {};
A.max = max(Alphas);
A.min = min(Alphas);

p_model = k_model(P, Alphas, 1, 20, false, true);
[~, rf_model] = k_model(R, Alphas, 1, 4, false, true);

%model = @(a,s,oc,or) get_path(cellfun(@double,cell(a)), cellfun(@double,cell(s)), cellfun(@double,cell(oc)), cellfun(@double,cell(or)), p_model, pf_model, rf_model, A);
model = @(a,s,oc,or) get_path(a, s, oc, or, p_model, rf_model, A);

save('../../../RealTime/model_path.mat','model');
end