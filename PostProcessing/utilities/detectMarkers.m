function is_marker = detectMarkers(foreground, is_obj, show_pin_seg, method)

if nargin < 4
    method = 4;
end

% RGB of the object


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
elseif method == 2
    U=uint8(foreground.*uint8(imerode(is_obj,strel('disk',4))));
    U(U<50)=255;
    Blobs = blob(U(:,:,2), 2);
    mask=ones(5);
    mask(3,3)=0;
    BlobPeak=(ordfilt2(Blobs,24,mask)<Blobs);
    StongBlobs = Blobs.*BlobPeak;
    
    A = ~imbinarize(uint8(double(U(:,:,2)).*double(U(:,:,3))/(255^2)));
    pts = imbinarize(medfilt2(U(:,:,2),[9,9])-U(:,:,2));
    pts = pts.*imdilate(A,strel('disk',3));
    pts = uint8(pts).*foreground;

    B = (double(pts).*StongBlobs);
    B = B/max(B(:));
    B = imdilate(B,strel('disk',5));
    pts = double(pts(:,:,1)).*(B(:,:,1)>0.35);
    pts = imbinarize(pts);
    pts = imclose(pts,strel('disk',3));

elseif method == 4 
     is_obj = double(is_obj>0);
     foreground = double(foreground);
     HSV = rgb2hsv(foreground);
     is_obj = imerode(is_obj,strel('disk',2));
     pts = imfill(HSV(:,:,3).*is_obj,'holes')-(HSV(:,:,3).*is_obj)>30;
elseif method == 5
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
    pts = imopen(imclose(imfill(HSV(:,:,3).*is_obj,'holes')-(HSV(:,:,3).*is_obj)>25,strel('disk',1)),strel('disk',1));
end


if show_pin_seg
    figure;
    imshow(uint8(pts).*foreground);
end   

elements = bwconncomp(pts);
is_marker = zeros(size(pts));
    % Separete the balls into independent binary images
    ind = 1;
    for num = 1:elements.NumObjects 
        if numel(elements.PixelIdxList{num})<50
            is_marker(elements.PixelIdxList{num}) = ind;
            ind = ind +1;
        end
    end
end

  