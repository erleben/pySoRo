
ordered = {};
name = 'exp1';
folder = strcat('experiment_3/output_',name,'/');
settings = makeSettings('13');
for i = 1:100

    settings = makeSettings('13');
    
    settings.pc_name_recon{1}=char(strcat('../../data/', folder, int2str(i),'_',settings.serial(1),'.ply'));
    settings.pc_name_recon{2}=char(strcat('../../data/', folder, int2str(i),'_',settings.serial(2),'.ply'));

    settings.fore_name_recon{1}=char(strcat('../../data/', folder, int2str(i),'_',settings.serial(1),'color.tif'));
    settings.fore_name_recon{2}=char(strcat('../../data/', folder, int2str(i),'_',settings.serial(2),'color.tif'));

    settings.tex_name_recon{1}=char(strcat('../../data/', folder, int2str(i),'_',settings.serial(1),'texture.tif'));
    settings.tex_name_recon{2}=char(strcat('../../data/', folder, int2str(i),'_',settings.serial(2),'texture.tif'));
 
    if i == 1
        order_to = getMarkerCentroids(settings);
        order_to.estimated = [];
        ordered{1} = order_to;

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