function [coord, displacement] = measureDistortion

show_all = true;
with_color = false;
segment = true;


serial = '618204002727';
%serial = '616205005055';
path_to_pcs = '../../data/reconstruction/';
path_to_calibration = '../../data/calibration/';

postfix_calib = '4';
postfix_calib = strcat('_',postfix_calib);
postfix = '4_3';
postfix = strcat('_',postfix);

fore = strcat(path_to_pcs, serial, postfix, 'color_fore.tif');
back = strcat(path_to_calibration, serial, postfix_calib, 'color_back.tif');

tex  = strcat(path_to_pcs, serial, postfix, 'texture_fore.tif');

isObj = getSegments(back, fore, false, 1);
isObj = {imerode(isObj{1}, strel('disk',30))};

PC_from = pcread(strcat(path_to_pcs, serial, postfix, '.ply'));

PC_from = getObjPointclouds(isObj, PC_from, tex);
PC_from = PC_from{1};

function v = point_plane_shortest_dist_vec(x, y, z, a,b,c,d)
% Point to plane shortest distance vector
% The plane is defined by: ax+by+cz+d = 0
% The point is defined by: x, y, and z

dist = (a*x+b*y+c*z+d) / sqrt(a^2+b^2+c^2);
N = [a; b; c]/norm([a; b; c]);
v = N.*dist;

end

plane = pcfitplane(PC_from, 1);
par = plane.Parameters;
coord = PC_from.Location;
displacement = coord;
for p = 1:PC_from.Count
    pt = PC_from.Location(p,:);
    v = point_plane_shortest_dist_vec(pt(1), pt(2), pt(3), par(1),par(2),par(3),par(4));
    %dist_PC(p,:)= dist_PC(p,:) - v';
    displacement(p,:)=  -v';
end
dist_PC = pointCloud(coord+displacement)
pcshow(dist_PC);


ugly_PC = pcread(strcat(path_to_pcs, serial, '_5_2', '.ply'));
nice_P = ugly_PC.Location;
for i = 1:ugly_PC.Count
    ind = findNearestNeighbors(dist_PC, ugly_PC.Location(i,:),1);
    nice_P(i,:) = nice_P(i,:) + displacement(ind,:);
end


 
end 