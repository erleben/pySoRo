n = 1;

for j = 1:16
for i = j:16:736
    I=imread(strcat('../../../../timelapse_r/',int2str(i), '_732612060774color.tif'));
    imwrite(I, strcat('../../../../timelapse_orderedR/',int2str(n),'.JPG'));
    n = n+1;
end
end