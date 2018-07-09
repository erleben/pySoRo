pre = '/Volumes/TOSHIBA/experiment5/';
name = '_806312060523color.tif';
%name = '_732612060774color.tif';


nrs = [1, 29, 1168, 1189];
I = {};
ind = 1;
d = 0;
for nr = nrs
    path = strcat(pre,int2str(nr),name);
    if d == 0
        [II, d] = imcrop(imread(path));
        I{ind} = II;
    else
        I{ind} = imcrop(imread(path),d);
    end
    ind = ind + 1;
end

for i = 1:length(nrs)
    figure;
imshow(I{i});
end