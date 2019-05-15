function [transformed_points] = applyCalibration(points, tform)
%APPLYCALIBRATION Summary of this function goes here
%   Detailed explanation goes here
transformed_points = (((tform.R).*(tform.S))*(points+tform.T)')';
end

