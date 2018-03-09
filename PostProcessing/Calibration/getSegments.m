% This funciton takes the path to a foreground and a background color
% image and returns a cell array of binary images. One for each object.
% binary(x,y) = 1 if there is a object at x,y in the foreground image.
function objects = getSegments(back_name, fore_name, fit_circle, max_num_obj)

if nargin < 4
    max_num_obj = inf;
end


foreground = double(imread(fore_name));
background = double(imread(back_name));
 
HSV = rgb2hsv(foreground-background);
if ~fit_circle
    % Since the background is black, we binarize the intensity channel of
    % the HSV image
     
    isObject = imbinarize(HSV(:,:,3));

    % Remove the string of the hagning ball
    isObject = imopen(isObject,strel('disk',4));

    % If it is so that the point cloud data quality is poor on the edges of the
    % objects, then eroding will remove the outermost points
    %isObject = imerode(isObject, strel('disk', 3));

    elements = bwconncomp(isObject);
    objects = {elements.NumObjects};
    largest_size = 0; 
    % Separete the balls into independent binary images
    for num = 1:min(elements.NumObjects, max_num_obj)
        if num > 1
            obj = bwareafilt(isObject, num) -bwareafilt(isObject,num-1);

        else
            obj = bwareafilt(isObject, num);
        end
        largest_size = max(largest_size, sum(obj(:)));

        if largest_size < sum(obj(:))*5
            obj = imfill(obj,'holes');
            objects{num, 1} = obj;
        end
    end
else
    [centers, radii] = imfindcircles(HSV(:,:,3),[20 50]);
    [M,N,~] = size(HSV); 
    for num = 1:length(radii)
        [cols rows] = meshgrid(1:M, 1:N);
        objects{num, 1} = ((rows - centers(num,1)).^2 + (cols - centers(num,2)).^2 <= radii(num).^2)';
    end
end 

end



