function T = translationCalibration(pc)
%TRANSLATION_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here
    location = pc.Location;
    new = location(:,1) < -10.0;
    T = mean(pc.Location);
end

