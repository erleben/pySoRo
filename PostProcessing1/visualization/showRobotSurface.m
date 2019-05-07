function a = showRobotSurface(pcloud,fig1, fig2)
%UNTITLED Summary of this function goes here
    if nargin < 2
        fig1 = 1;
    end
    if nargin < 3
        fig2 = 2;
    end

    a = 0;
    figure();
    pc = pointCloud(pcloud.Location, 'Color', pcloud.Color);
    pcshow(pc);
    figure();
    pcshow([pcloud.Location(:,1), pcloud.Location(:,2), pcloud.Location(:,3)]);
    
end

