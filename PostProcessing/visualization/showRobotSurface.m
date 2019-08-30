function a = showRobotSurface(pcloud, caption, fig1, fig2)
%UNTITLED Summary of this function goes here
    if nargin < 2
        caption = "PointCloud plot";
    end
    if nargin < 3
        fig1 = 1;
    end
    if nargin < 4
        fig2 = 2;
    end

    % Show colorized point clouds
    figure(fig1);
    pc = pointCloud(pcloud.Location, 'Color', pcloud.Color);
    pcshow(pc);
    xlabel('x(mm)');
    ylabel('y(mm)');
    zlabel('z(mm)');
    view([180,-90]);
    %title(strcat(caption, ' with color'));
    
    % Show depth map
    figure(fig2);
    pcshow([pcloud.Location(:,1), pcloud.Location(:,2), pcloud.Location(:,3)]);
    xlabel('x(mm)');
    ylabel('y(mm)');
    zlabel('z(mm)');
    view([180,-90]);
    %title(strcat(caption, ' depth intensity'));
end

