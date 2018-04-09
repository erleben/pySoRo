function object_pcs = getObjPointclouds(objects, pc, tex_name)

[height, width] = size(objects{1});

% Texture coordinates is a mapping from point index in the point cloud to
% a tuple (u,v) where (u*height, v*width) are  the coordinates of where the 
% color is taken from in the color image.
% Librealsense point clouds do not include invalid points, but texture
% coordinates does. Invalid points have the value (0,0) in the texture
% coordinates
tex = imread(tex_name);
tex = double(tex);
% Find valid points
ispoint = logical((tex(:,1)~=0).*(tex(:,2)~=0));

% To get the coordinates, we have to multiply by the width and height of
% the color image
tex_imco = round(tex.*[width,height]);
[numObj, ~] = size(objects);

% For each object, find the point cloud indices that correspond to points
% in that object
for num = 1:numObj
    isObj = objects(num,1);
    isObj = isObj{1};
    if sum(isObj(:)) < 6
        isObj = imdilate(isObj, strel('disk', 1));
    end
    
    isObjList = zeros(width*height,1);
    for i = 1:length(tex_imco)
        x = tex_imco(i,1);
        y = tex_imco(i,2);
        
        if (x<width) && (x>0) && (y<height) && (y>0)
            if isObj(y,x) == 1
                isObjList(i) = 1;
            end
            
        end
    end
    
    % Remove invalid points
    isObjList = logical(isObjList(ispoint,:));
    
    % Extract points that belong to the object
    Loc = pc.Location;  
    Loc(~isObjList,:)=[];
    Col = pc.Color;
    Col(~isObjList,:)=[];
     
    % Create a separeate pointcloud for the object
    object_pcs{num} = pointCloud(Loc,'Color',Col);
end
 

 
end