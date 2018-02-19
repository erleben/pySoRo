function spheremodels = getSphereModels(sphere_pcs, pc, showClouds)

num_balls = length(sphere_pcs);

for num = 1:num_balls
    spheremodels{num} = pcfitsphere(sphere_pcs{num}, 0.001);
end

% Could include the floor to make sure the balls dont go through it
% Would have to merge pc with background pc
% for num = 1:num_balls
%     ROI = pc.select(pc.findNeighborsInRadius(spheremodels{num}.Center,spheremodels{num}.Radius*1.2));
%     spheremodels{num} = pcfitsphere(ROI,0.001);
% end
 
if showClouds
    pcshow(pc);
    hold on;
    for num = 1:num_balls
        plot(spheremodels{num});
        hold on;
    end
end


end
