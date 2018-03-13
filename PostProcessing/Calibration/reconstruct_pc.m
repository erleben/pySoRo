clear;

segment = true;
with_color = true;

settings = makeSettings(["618204002727", "616205005055"], '../../data/calibration/', '_4', '../../data/reconstruction/', '_4_4');

PC_from = pcread(settings.pc_name_recon{1});
PC_to = pcread(settings.pc_name_recon{2});

tform = load(settings.tform_name);


if segment
    
    isObj_1 = getSegments(settings.back_name{1}, settings.fore_name_recon{1}, false, 1);
    isObj_2 = getSegments(settings.back_name{2}, settings.fore_name_recon{2}, false, 1);
    
    PC_from = getObjPointclouds(isObj_1, PC_from, settings.tex_name_recon{1});
    PC_from = PC_from{1};
    PC_to = getObjPointclouds(isObj_2, PC_to, settings.tex_name_recon{2});
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

getMarkerCentroids(settings)