clear;

segment = true;
with_color = false;

serial_1 = '618204002727';
serial_2 = '616205005055';
path_to_pcs = '../../data/reconstruction/';
path_to_calibration = '../../data/calibration/';

postfix_calib = '3';
postfix_calib = strcat('_',postfix_calib);
postfix = '3_1';
postfix = strcat('_',postfix);

tform_name = strcat(path_to_calibration, 'tform', postfix_calib, '.mat');
tform = load(tform_name);

PC_from = pcread(strcat(path_to_pcs, serial_1, postfix, '.ply'));
PC_to = pcread(strcat(path_to_pcs, serial_2, postfix, '.ply'));




if segment
    fore_1 = strcat(path_to_pcs, serial_1, postfix, 'color_fore.tif');
    back_1 = strcat(path_to_calibration, serial_1, postfix_calib, 'color_back.tif');
    fore_2 = strcat(path_to_pcs, serial_2, postfix, 'color_fore.tif');
    back_2 = strcat(path_to_calibration, serial_2, postfix_calib, 'color_back.tif');
    tex_1  = strcat(path_to_pcs, serial_1, postfix, 'texture_fore.tif');
    tex_2  = strcat(path_to_pcs, serial_2, postfix, 'texture_fore.tif');
    
    isObj_1 = getSegments(back_1, fore_1, 1, false);
    isObj_2 = getSegments(back_2, fore_2, 1, false);
    
    PC_from = getObjPointclouds(isObj_1, PC_from, tex_1);
    PC_from = PC_from{1};
    PC_to = getObjPointclouds(isObj_2, PC_to, tex_2);
    PC_to = PC_to{1};
end 

if ~with_color
    PC_from = pointCloud(PC_from.Location);
    PC_to = pointCloud(PC_to.Location);
end

from_transformed = zeros(PC_from.Count,3);
from_points = PC_from.Location;

for i = 1:PC_from.Count
    from_transformed(i,:)=(tform.R*from_points(i,:)')'+tform.T';
end
from_transformed_PC = pointCloud(from_transformed, 'Color', PC_from.Color);


PC_merged = pcmerge(PC_to,from_transformed_PC, 0.0001);

figure;
subplot(1,2,1);
pcshow(from_transformed_PC);
title('moving');
view([0 -90])
subplot(1,2,2);
pcshow(PC_to);
title('fixed');
view([0 -90])

figure;
pcshow(PC_merged);
title('Pointclouds merged');
view([0 -90])

 from_transformed_PC = pcdownsample(from_transformed_PC,'gridAverage',0.001);
 PC_to = pcdownsample(PC_to,'gridAverage',0.001);

% Use the ICP algorithm to improve alignment
[tform, ICP_PC, dist] = pcregrigid(from_transformed_PC, PC_to,'InlierRatio', 0.1);
figure;
pcshow(ICP_PC);
title('ICP');
view([0 -90])

figure;
tf = affine3d(tform.T);
pcshow(pcmerge(PC_to, pctransform(from_transformed_PC,tf),0.001),'Markersize',140)
title('Merged pointclouds based on ICP transform');

