function [calibration,C] = getCalibrationUnit(settings, calibrationUnit, margin)
%GETCALIBRATIONUNIT Summary of this function goes here
%   Detailed explanation goes here

    % Extract yellow ball, and center around that.
    for k = 1:2
        pc1_raw = pcread(settings.pc_name_recon{k});
        pc_close = findNeighborsInRadius(pc1_raw, median(pc1_raw.Location), 0.5);
        pc1 = pointCloud(pc1_raw.Location(pc_close,:),'Color', pc1_raw.Color(pc_close,:));
    
        % Convert to gray scale
        gray = [pc1.Color(:,1).*0.2989 + pc1.Color(:,2).*0.5870 + pc1.Color(:,3).*0.1140];
        % Filter gray scale pixels
        fore = gray > 70;
        % Find yellow ball in non-black pixels.
        red = pc1.Color(:,1) < 220;
        green = pc1.Color(:,2) < 210;
        blue = pc1.Color(:,3) < 40;
        mask = fore & red & green & blue;
        pc2 = pointCloud(pc1.Location(mask,:), 'Color', pc1.Color(mask,:));
        % Re-adjust neighborhood of points to be sorrounding the calibration
        % artifact.
        pc_close = findNeighborsInRadius(pc1_raw, median(pc2.Location), 0.1);
        pc3 = pointCloud(pc1_raw.Location(pc_close,:),'Color', pc1_raw.Color(pc_close,:));
    
        % Extract individual spheres.
        gray = [pc3.Color(:,1).*0.2989 + pc3.Color(:,2).*0.5870 + pc3.Color(:,3).*0.1140];
        fore = gray > 120;
        mask = fore;
        % Identify all non-black parts
        pc4 = pointCloud(pc3.Location(mask,:),'Color', pc3.Color(mask,:));
        % Cluster each partial sphere into 4 clusters
        [idx,C{k}] = kmeans(double(pc4.Location), 4);
        % Select all inliers in each cluster.
        for i = 1:4
            calibration{6*(k-1)+i} = select(pc3, find(idx == i));
        end
        % Provide the whole calibration element for visualization
        calibration{(k-1)*6+5} = pc3;
        calibration{(k-1)*6+6} = pc4;
    end
end

