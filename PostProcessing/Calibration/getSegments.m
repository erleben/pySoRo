% This funciton takes the path to a foreground and a background color
% image and returns a cell array of binary images. One for each object.
% binary(x,y) = 1 if there is a object at x,y in the foreground image.
function objects = getSegments(back_name, fore_name, max_num_obj)

if nargin < 3
    max_num_obj = inf;
end

foreground = imread(fore_name);
background = imread(back_name);


% Since the background is black, we binarize the intensity channel of
% the HSV image
HSV = rgb2hsv(foreground-background);
isObject = imbinarize(HSV(:,:,3));

% Remove the string of the hagning ball
isObject = imopen(isObject,strel('disk',4));

% If it is so that the point cloud data quality is poor on the edges of the
% objects, then eroding will remove the outermost points
%isBall = imerode(isBall, strel('disk', 3));
elements = bwconncomp(isObject);
objects = {elements.NumObjects, 1};

% Separete the balls into independent binary images
for num = 1:min(elements.NumObjects, max_num_obj)
    if num > 1
        obj = bwareafilt(isObject, num) -bwareafilt(isObject,num-1);
    else
        obj = bwareafilt(isObject, num);
    end
    objects{num, 1} = obj;
end

end



