function is_marker = detectMarkers(foreground, is_obj, show_pin_seg, method)

if nargin < 4
    method = 5;
end

% There is no best way to segment images. Light conditions and size and 
% color of robot and markers influence the results.
% Chose between the five methods bellow to find one that works well for
% your robot.


if method == 1
    U=uint8(foreground.*uint8(imerode(is_obj,strel('disk',4))));
    U(U<50)=255;
    A = ~imbinarize(uint8(double(U(:,:,2)).*double(U(:,:,3))/(255^2)));

    pts = imbinarize(medfilt2(U(:,:,2),[9,9])-U(:,:,2));
    pts = pts.*imdilate(A,strel('disk',3));
    pts = uint8(pts).*foreground;
    pts = pts(:,:,1)>200;
    pts = imclose(pts,strel('disk',5));
    pts = imopen(pts,strel('disk',1)); 

elseif method == 3
     is_obj = double(is_obj>0);
     foreground = double(foreground);
     HSV = rgb2hsv(foreground);
     is_obj = imerode(is_obj,strel('disk',2));
     pts = imfill(HSV(:,:,3).*is_obj,'holes')-(HSV(:,:,3).*is_obj)>30;
elseif method == 4
    % Check ration between blue and red. Is high for markers, close to 1 for
    % background
    is_obj = double(is_obj>0);
    foreground = double(foreground);
    is_obj = imerode(is_obj,strel('disk',2));
    pts = (foreground(:,:,3)./foreground(:,:,1).*is_obj)>1.2;
else
    is_obj = double(is_obj>0);
    is_obj = imerode(is_obj,strel('disk',2));
    foreground = double(foreground);
    HSV = rgb2hsv(foreground);
    pts = imopen(imclose(imfill(HSV(:,:,3).*is_obj,'holes')-(HSV(:,:,3).*is_obj)>55,strel('disk',1)),strel('disk',1));
end


if show_pin_seg
    figure;
    imshow(uint8(pts).*foreground);
end   

% Enumerate the segmented markers such that each marker has a unique value in is_marker
elements = bwconncomp(pts);
is_marker = zeros(size(pts));
ind = 1;
for num = 1:elements.NumObjects
    if numel(elements.PixelIdxList{num})<50
        is_marker(elements.PixelIdxList{num}) = ind;
        ind = ind +1;
    end
end
end

  
