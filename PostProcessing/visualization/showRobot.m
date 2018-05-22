
folder = strcat('/Volumes/TOSHIBA/experiment3/');
settings = makeSettings('15');

i = 1;
imshow(char(strcat(folder, 1,'_',settings.serial(1),'color.tif')));


for a1 = 1:60:300
    for a2 = 1:60:300
        i = a1*300+a2;
        
        settings.fore_name_recon{1}=char(strcat(folder, int2str(i),'_',settings.serial(1),'color.tif'));
        settings.fore_name_recon{2}=char(strcat(folder, int2str(i),'_',settings.serial(2),'color.tif'));
        imshow(settings.fore_name_recon{1});
    end
end