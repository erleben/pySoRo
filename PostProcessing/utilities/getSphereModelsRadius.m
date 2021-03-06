function spheremodels = getSphereModelsRadius(sphere_pcs, pc, showClouds, radius)

% This function takes the radius into account. It finds the point of the
% ball that is closest to the camera and projects into the center of it by
% moving radius units in the z-direction. This approach is sensitive to
% noise in the data. 

num_balls = length(sphere_pcs);

for num = 1:num_balls
    %Fit a sphere to the points
    mdl = pcfitsphere(sphere_pcs{num}, 0.001);
    % Extract points that are near this sphere
    ROI=sphere_pcs{num}.select(findNeighborsInRadius(sphere_pcs{num},mdl.Center, mdl.Radius*1.2));
    % Extract the points closest to the camera
    B=ROI.Location(ROI.Location(:,3)==min(ROI.Location(:,3)),:);
    %Compute the mean x and y coordinate 
    
    center = mean(B,1);
    center(3) = center(3)+radius;

    spheremodels{num} = sphereModel([center,radius]);
end
 
if showClouds
    pc_close = findNeighborsInRadius(pc, median(pc.Location), 0.5);
    pc= pointCloud(pc.Location(pc_close,:),'Color', pc.Color(pc_close,:));
    pcshow(pc);
    hold on;
    for num = 1:num_balls
        plot(spheremodels{num});
        hold on;
    end
end


end 
