function a = showRobotSurface(pcloud)
%UNTITLED Summary of this function goes here

    a = 0;
    figure();    
    pc = pointCloud(pcloud.Location, 'Color', pcloud.Color);
    pcshow(pc);
    figure();
    pcshow([pcloud.Location(:,1), pcloud.Location(:,2), pcloud.Location(:,3)]);
    
end

