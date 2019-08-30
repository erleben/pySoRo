function a = visualizePointCloud(pc1,fig)
%VISUALIZEPOINTCLOUD Summary of this function goes here
%   Detailed explanation goes here
    addpath('../utilities/');
    p = double(pc1.Location);
    [t]=MyCrustOpen(p);
    figure(fig);
    set(gcf,'position',[0,0,1280,800]);
    subplot(1,2,1)
    hold on
    axis equal
    title('Points Cloud','fontsize',14)
    plot3(p(:,1),p(:,2),p(:,3),'g.')
    axis vis3d
    view(3)
    % plot the output triangulation
    figure(fig)
    subplot(1,2,2)
    hold on
    title('Output Triangulation','fontsize',14)
    axis equal
    trisurf(t,p(:,1),p(:,2),p(:,3),'facecolor','c','edgecolor','b')%plot della superficie
    axis vis3d
    view(3)
    a=1;
end

