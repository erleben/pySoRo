clear;

id = '8';
id = strcat('_',id);
subid = strcat('8_5');
subid = strcat('_',subid);
settings = makeSettings(["618204002727", "616205005055"], '../../data/calibration/', id, '../../data/reconstruction/', subid);
[order_to, tform] = getMarkerCentroids(settings);
order_to.common = [(1:size(order_to.common,1))', order_to.common];
order_to.exclusive = [(1:size(order_to.exclusive,1))', order_to.exclusive];

ordered = {};
ordered{1} = order_to;

ind = 2;
for i = 6:9
    id = '8';
    id = strcat('_',id);
    subid = strcat('8_',int2str(i));
    subid = strcat('_',subid);
    
    settings = makeSettings(["618204002727", "616205005055"], '../../data/calibration/', id, '../../data/reconstruction/', subid);
    [order_from, tform] = getMarkerCentroids(settings, tform);
    
    [tracked_common, untracked_common] = order_markers(order_to.common, order_from.common);
    [tracked_exclusive, untracked_exclusive] = order_markers(order_to.exclusive, order_from.exclusive);

    order_from = {};
    order_from.common = tracked_common;
    order_from.exclusive = tracked_exclusive;
    ordered{ind} = order_from;
    ind = ind + 1;
    
    order_to = order_from;

end