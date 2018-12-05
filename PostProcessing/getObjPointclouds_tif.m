function object_pcs = getObjPointclouds_tif(objects, pc)

[height, width] = size(objects);


object_pcs = {};
numObj = max(objects(:));

for num = 1:numObj
    isObj = objects==num;
    if sum(isObj(:)) < 6
        isObj = imdilate(isObj, strel('disk', 1));
    end
    
    
    loc = pc.Location;
    x = loc(:,1);
    y = loc(:,2);
    z = loc(:,3);
    
    x=reshape(x,width,height)';
    y=reshape(y,width,height)';
    z=reshape(z,width,height)';
    
    pts = [x(isObj), y(isObj), z(isObj)];
    object_pcs{num} = pointCloud(pts);
   
end


 
end