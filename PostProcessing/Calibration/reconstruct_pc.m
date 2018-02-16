
%make a function
% find a good way to store T, R, color, tex and PCS
segment = false;

serial_1 = '618204002727';
serial_2 = '616205005055';
directory = 'pointclouds/';

PC_from = pcread(strcat(directory,serial_1,'.ply'));
PC_to = pcread(strcat(directory,serial_2,'.ply'));

if segment
    fore_1;
    back_1;
    fore_2;
    back_2;
    tex_1;
    tex_2;
    
    isObj_1 = getSegments(fore_1, back_1, 1);
    isObj_2 = getSegments(fore_2, back_2, 1);
    
    PC_from = getObjPointclouds(isObj_1, PC_from, tex_1);
    PC_to = getObjPointclouds(isObj_2, PC_to, tex_2);
end

from_transformed = zeros(PC_from.Count,3);
from_points = PC_from.Location;

for i = 1:PC_from.Count
    from_transformed(i,:)=(R*from_points(i,:)')'+T';
end
from_transformed_PC = pointCloud(from_transformed, 'Color', PC_from.Color);


PC_merged = pcmerge(PC_to,from_transformed_PC, 0.0001);

figure;
pcshow(PC_merged);

% figure;
% pcshow(PC_merged);
% hold on;
% plot(pcshow(pcfitcylinder(PC_merged, 0.01)));
% plot(pcshow(pcfitplane(PC_merged, 0.01)));
