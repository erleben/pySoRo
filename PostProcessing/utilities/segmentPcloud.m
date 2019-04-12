function pcloud1 = segmentPcloud(pcloud, tred, tgreen, tblue, r, tgray)
    %SEGMENTPCLOUD Summary of this function goes here
    %   Detailed explanation goes here
    if nargin < 2
        tred = 100;
    end
    if nargin < 3
        tgreen = 100;
    end
    if nargin < 4
        tblue = 100;
    end
    if nargin < 5
        r = 0.17;
    end
    if nargin < 6
        % Read in the two perspectives.
        %pcloud1 = pcread(settings.pc_name_recon{1});
        %pcloud2 = pcread(settings.pc_name_recon{2});
    
        %
        % Segment first point cloud
        %
        pc_close = findNeighborsInRadius(pcloud, median(pcloud.Location), 0.7);
        pc1 = pointCloud(pcloud.Location(pc_close,:),'Color', pcloud.Color(pc_close,:));
    
        % Filter red color channel
        channel1 = (find(pc1.Color(:,1) > tred));
        pcred = pointCloud(pc1.Location(channel1,:), 'Color', pc1.Color(channel1,:));
    
        % Filter green color channel
        channel2 = (find(pcred.Color(:,2) > tgreen));
        pcgreen = pointCloud(pcred.Location(channel2,:), 'Color', pcred.Color(channel2,:));
    
        % Filter blue color channel
        channel3 = (find(pcgreen.Color(:,2) > tblue));
        pcblue = pointCloud(pcgreen.Location(channel3,:), 'Color', pcgreen.Color(channel3,:));
        
        %filter_coordinates = find(pcblue.Location(:,3) > 0.6);
        %pcblue = pointCloud(pcblue.Location(filter_coordinates, :), 'Color', pcblue.Color(filter_coordinates,:));
        
        % Reconstruct point cloud in smaller radius, yielding area of interest.
        pc_close = findNeighborsInRadius(pcblue, median(pcblue.Location), r);
        pcloud1 = pointCloud(pcblue.Location(pc_close,:),'Color', pcblue.Color(pc_close,:));
        
        
    end
    if nargin > 5
        % Filter using Grayscale
        pc_close = findNeighborsInRadius(pcloud, median(pcloud.Location), 0.7);
        pc1 = pointCloud(pcloud.Location(pc_close,:),'Color', pcloud.Color(pc_close,:));
        gray_inds = ((pc1.Color(:,1).*0.3 + pc1.Color(:,2).*0.59 + pc1.Color(:,3).*0.11) > tgray);
        pcloud_gray = pointCloud(pc1.Location(gray_inds,:), 'Color', pc1.Color(gray_inds,:));
        pc_close = findNeighborsInRadius(pcloud_gray, median(pcloud_gray.Location), r);
        pcloud1 = pointCloud(pcloud_gray.Location(pc_close,:),'Color', pcloud_gray.Color(pc_close,:));
    end

   
end

