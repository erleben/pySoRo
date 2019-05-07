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
                                [4.05, 0, 0];
                               [0,0,5.05];
                                [0,3.05,0]];
CalibrationUnit.color = [169.0, 104.0, 54.0;
         142, 0, 0;         
         210, 155, 0;
         33, 64, 0;
         ];


radius = 0.001;
% added scale factor from camera space to real_world measurements.
for i = 20:20
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
    
    [calibration, C] = getCalibrationUnit(settings, CalibrationUnit, 30.0);
    for j = 7:12
        figure();
        pcshow(calibration{j});
    end
    
end

%%
[x,y,z] = sphere;
radius = 0.007;
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

addpath('visualization/');
calibrationUnit = [[0,0,0];
                   [4.05, 0, 0];
                   [0,0,5.05];
                   [0,3.05,0]];
color = [rgbColor(169.0, 104.0, 54.0);
         rgbColor(142, 0, 0);         
         rgbColor(210, 155, 0);
         rgbColor(33, 64, 0);
         ];
figure();
scatter3(calibrationUnit(:,1),calibrationUnit(:,2),calibrationUnit(:,3), 75, color, 'filled');