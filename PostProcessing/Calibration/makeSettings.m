function settings = makeSettings(serial, path_to_calib, id, path_to_pcs, subid)

settings = {};

if nargin < 5
    settings.subid = '_4_1';
else
    settings.subid = subid;
end

if nargin < 4
    settings.path_to_pcs = '../../data/reconstruction/';
else
    settings.path_to_pcs = path_to_pcs;
end

if nargin < 3
    settings.id = '_4';
else
    settings.id = id;
end

if nargin < 2
    settings.path_to_calib = '../../data/calibration/';
else
    settings.path_to_calib = path_to_calib;
end

if nargin < 1
    settings.serial = ["618204002727", "616205005055"];
else
    settings.serial = serial;
end

for cam_no = 1:length(settings.serial)
    path_calib = strcat(settings.path_to_calib, settings.serial(cam_no), settings.id);
    path_recon = strcat(settings.path_to_pcs, settings.serial(cam_no), settings.subid);
    
    settings.back_name{cam_no} = char(strcat(path_calib, 'color_back.tif'));
    settings.fore_name{cam_no} = char(strcat(path_calib, 'color_fore.tif'));
    settings.tex_name{cam_no} = char(strcat(path_calib, 'texture_fore.tif'));
    settings.pc_name_calib{cam_no} = char(strcat(path_calib, 'fore.ply'));
    
    settings.pc_name_recon{cam_no} = char(strcat(path_recon, '.ply'));
    settings.fore_name_recon{cam_no} = char(strcat(path_recon, 'color_fore.tif'));
    settings.tex_name_recon{cam_no} = char(strcat(path_recon, 'texture_fore.tif'));
end

settings.tform_name = strcat(settings.path_to_calib, 'tform', settings.id,'.mat');


end
