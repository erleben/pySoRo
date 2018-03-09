function is_marker = detectMarkers(foreground, is_obj)

% RGB of the object
U=uint8(foreground.*uint8(is_obj));

%Assuming red pinheads as markers:
im = U(:,:,1)-U(:,:,2);
pts = im>50;

imshow(pts)

elements = bwconncomp(pts);
is_marker = {elements.NumObjects};
    % Separete the balls into independent binary images
    for num = 1:elements.NumObjects
        if num > 1
            obj = bwareafilt(pts, num) -bwareafilt(pts,num-1);

        else
            obj = bwareafilt(pts, num);
        end

        is_marker{num} = obj;
    end
    
end

 