% Finds the rigid transformation [R,T] that maps points in coordinate system
% A to coordinate system B. It is assumed that calibration data has been
% gathered for each of the cameras, (see
% pySoRo/DataAcqusition/pyCALIBRATE). The settings object contains paths to
% the data. See utils/makeSeettings.m


addpath('utilities/');

settings = makeSettings('5', '1', ["821312062271", "732612060774"], '../../calibration5/','../../experiment5/');
folder = settings.path_to_pcs;
% Initial calibration measurement initialization and coloring.
CalibrationUnit.coordinates = [[0,0,0];
                               [40.5, 0, 0];
                               [0,30.5,0];
                               [0,0,50.5]];
CalibrationUnit.color = [169.0, 104.0, 54.0;
         142, 0, 0;         
        33, 64, 0;         
         210, 155, 0];

%%
radius = 0.002;
% added scale factor from camera space to real_world measurements.
for i = 1:1
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
    
    [calibration, C] = getCalibrationUnit(settings, CalibrationUnit, [70.0,0.0]);
    %[R,T, mse, in] = getTransformRansac(C{1}, C{2}, 4);
    
    for j = 1:6
        figure();
        pcshow(calibration{j});
        xlabel('x');
        ylabel('y');
        zlabel('z');
        grid on;
    end
    
end
%%
[x,y,z] = sphere;
radius = 0.01;
x = x*radius;
y = y*radius;
z = z*radius;
for b =1:2
    figure();
    hold on;
    for a = 1:4
        pcshow(calibration{5+6*(b-1)});
        center = C{b}(a,:);
        surf(x+center(1), y+center(2), z+center(3));
        hold on;
    end
    hold off;
end
view([0 -90])
%%
[R1,T1,S1, mse] = getWorldCalibration(CalibrationUnit, C{1}, C{2});
%
tform1.R = R1{1};
tform1.T = T1{1};
tform1.S = S1{1};
tform2.R = R1{2};
tform2.T = T1{2};
tform2.S = S1{2};
tform{1} = tform1;
tform{2} = tform2;


%%
pc1_raw = pcread(settings.pc_name_recon{b});
pc_close = findNeighborsInRadius(pc1_raw, median(pc1_raw.Location), 0.3);
pc1 = pointCloud(pc1_raw.Location(pc_close,:),'Color', pc1_raw.Color(pc_close,:));
%%

I = pcloud2rgb(pc1);

%%

tform1.R1
tform2.R1
%%
"MSE : " + mse

[x,y,z] = sphere;
radius = 8.25;
x = x*radius;
y = y*radius;
z = z*radius;
figure();

for a =1:4
    center1 = applyCalibration(C{1}(a,:), tform1);
    center2 = applyCalibration(C{2}(a,:), tform2);
    %center2 = ((R{2}.*S{1})*(C{2}(a,:)+T{2})')';
    surf(x+center1(1), y+center1(2), z+center1(3));
    hold on;
    surf(x+center2(1), y+center2(2), z+center2(3));
end
view([0 -90])
hold off;
%%
locationsmerged = [];    
colorsmerged = [];
for b =1:2
    pc1_raw = pcread(settings.pc_name_recon{b});
    pc_close = findNeighborsInRadius(pc1_raw, median(pc1_raw.Location), 0.3);
    pc1 = pointCloud(pc1_raw.Location(pc_close,:),'Color', pc1_raw.Color(pc_close,:));
    
    coord1 = applyCalibration(pc1.Location, tform{b});
    locationsmerged = [locationsmerged; coord1];
    colorsmerged = [colorsmerged; pc1.Color];
end

pc_merged = pointCloud(locationsmerged, 'Color', colorsmerged);
pc_close = findNeighborsInRadius(pc_merged, median(pc_merged.Location), 300);
pc = pointCloud(pc_merged.Location(pc_close,:),'Color', pc_merged.Color(pc_close,:));
denoised_pc = pcdenoise(pc);
figure();
pcshow(denoised_pc);
% hold on;
% scatter3(CalibrationUnit.coordinates(:,1), ...
%          CalibrationUnit.coordinates(:,2), ...
%          CalibrationUnit.coordinates(:,3), ...
%          8.25, color, 'filled');
hold off;
view([0 -90])




%%

addpath('visualization/');
calibrationUnit = [[0,0,0];
                    [0,3.05,0];
                   [4.05, 0, 0];
                   [0,0,5.05]
                   ];
color = [rgbColor(169.0, 104.0, 54.0);
rgbColor(33, 64, 0);         
rgbColor(142, 0, 0);         
         rgbColor(210, 155, 0);
         
         ];
figure();
scatter3(calibrationUnit(:,1),calibrationUnit(:,2),calibrationUnit(:,3), 75, color, 'filled');