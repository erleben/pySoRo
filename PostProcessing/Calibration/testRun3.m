
ordered = {};
name = 'exp_twop1';
folder = strcat('/Volumes/TOSHIBA/experiment2/');
settings = makeSettings('13');
for i = 1:51

    settings = makeSettings('13');
    
    settings.pc_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'texture.tif'));
 
    if mod(i,51)==1
        order_to = getMarkerCentroids(settings);
        order_to.estimated = [];
        ordered{i} = order_to;

    else
        order_from = getMarkerCentroids(settings);
    

        [tracked_all, estimated] = order_markers(order_to.all, order_from.all);

        order_from = {};
        order_from.all = tracked_all;
        order_from.estimated = estimated;
        ordered{i} = order_from;

        order_to = order_from;
    end
    
    
end
cleanAndStore(ordered, name)