function [points, sphere_pcs] = getPoints(cam_no, settings, radius, use_radius, fit_circle)


back_name = settings.back_name{cam_no};
fore_name = settings.fore_name{cam_no};
tex_name  = settings.tex_name{cam_no};
pc_name = settings.pc_name_calib{cam_no};

pc = pcread(pc_name);

balls = getSegments(back_name, fore_name, fit_circle);

sphere_pcs = getObjPointclouds(balls, pc, tex_name);

if ~use_radius
    sphere_models = getSphereModels(sphere_pcs, pc, true);
else
    sphere_models = getSphereModelsRadius(sphere_pcs, pc, true, radius);
end

numBalls = length(sphere_models);
points = zeros(numBalls,3);
for num = 1:numBalls
    points(num,:)=sphere_models{num}.Center;
end

end