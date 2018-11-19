function settings = makeSettings(id, subid, serial, path_to_calib, path_to_pcs)

settings = {};


if nargin < 5
    settings.path_to_pcs = '../data/reconstruction/';
else
    settings.path_to_pcs = path_to_pcs;
end


if nargin < 4
    settings.path_to_calib = 'C:\Users\kerus\Documents\GitHub\data\calibration\';
else
    settings.path_to_calib = path_to_calib;
end

if nargin < 3
    settings.serial = ["732612060774", "821312062271"];
    %settings.serial = ["806312060523", "732612060774"];
else
    settings.serial = serial;
end

if nargin < 2
    settings.subid = '1';
else
    settings.subid = subid;
end

if nargin < 1
    settings.id = '4';
    settings.calib_id = '4';
else
    split = strsplit(id,',');
    if length(split)>1
        settings.id = split{1};
        settings.calib_id = split{2};
    else
        settings.id = id;
        settings.calib_id = id;
    end
end

id = strcat('_',settings.id);
calib_id = strcat('_',settings.calib_id);
subid = strcat(id,'_',settings.subid');

for cam_no = 1:length(settings.serial)
    path_calib = strcat(settings.path_to_calib, settings.serial(cam_no), calib_id);
    path_recon = strcat(settings.path_to_pcs, settings.serial(cam_no), subid);
    
    settings.back_name{cam_no} = char(strcat(path_calib, 'color_back.tif'));
    settings.fore_name{cam_no} = char(strcat(path_calib, 'color_fore.tif'));
    settings.tex_name{cam_no} = char(strcat(path_calib, 'texture_fore.tif'));
    settings.pc_name_calib{cam_no} = char(strcat(path_calib, 'fore.ply'));
    
    settings.pc_name_recon{cam_no} = char(strcat(path_recon, '.ply'));
    settings.fore_name_recon{cam_no} = char(strcat(path_recon, 'color_fore.tif'));
    settings.tex_name_recon{cam_no} = char(strcat(path_recon, 'texture_fore.tif'));
end

settings.tform_name = strcat(settings.path_to_calib, 'tform', id,'.mat');


end
