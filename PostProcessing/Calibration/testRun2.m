
ordered = {};

for i = 1:100

    settings = makeSettings('12');
    
    settings.pc_name_recon{1}=strcat('../../data/output/',int2str(i),'_618204002727.ply');
    settings.pc_name_recon{2}=strcat('../../data/output/',int2str(i),'_616205005055.ply');

    settings.fore_name_recon{1}=strcat('../../data/output/',int2str(i),'_618204002727color.tif');
    settings.fore_name_recon{2}=strcat('../../data/output/',int2str(i),'_616205005055color.tif');

    settings.tex_name_recon{1}=strcat('../../data/output/',int2str(i),'_618204002727texture.tif');
    settings.tex_name_recon{2}=strcat('../../data/output/',int2str(i),'_616205005055texture.tif');

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