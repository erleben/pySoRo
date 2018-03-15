function is_marker = detectMarkers(foreground, is_obj, show_pin_seg)

% RGB of the object
U=uint8(foreground.*uint8(is_obj));

%Assuming red pinheads as markers:
im = U(:,:,1)-U(:,:,2);
pts = imclose(im,strel('disk',10))>60;

if show_pin_seg
    figure;
    imshow(uint8(pts).*foreground);
end

elements = bwconncomp(pts);
is_marker = {elements.NumObjects}; 
    % Separete the balls into independent binary images
    ind = 1;
    for num = 1:elements.NumObjects
        if numel(elements.PixelIdxList{num})<50
            obj = zeros(size(im));
            obj(elements.PixelIdxList{num}) = 1;
            is_marker{ind} = obj;
            ind = ind +1;
        end
    end
    
end

  