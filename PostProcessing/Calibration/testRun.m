%clear;


settings = makeSettings('8','5');
[order_to, tform] = getMarkerCentroids(settings);
order_to.estimated = [];
%order_to.all(3,:) = [];
%order_to.all = [(1:size(order_to.all,1))', order_to.all];

ordered = {};
ordered{1} = order_to;

ind = 2;

for i = 6:9

    settings = makeSettings('8',int2str(i));
    [order_from, tform] = getMarkerCentroids(settings, tform);
    %order_from.all(randsample(12,floor(rand(1)*4)+1),:)=[];
    %order_from.all(4,:)=[];
   
    [tracked_all, estimated] = order_markers(order_to.all, order_from.all);
     
    order_from = {};
    order_from.all = tracked_all;
    order_from.estimated = estimated;
    ordered{ind} = order_from;
    ind = ind + 1;
    
    order_to = order_from;

end