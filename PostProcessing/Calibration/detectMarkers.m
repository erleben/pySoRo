function is_marker = detectMarkers(foreground, is_obj, show_pin_seg)

method = 3;

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

else 
 %   bw = is_obj.*double(foreground(:,:,2));
 %   pts = imopen((imfill(bw,'holes')-bw)>30,strel('disk',1));
 %   pts = imerode(pts, strel('disk', 1));
     HSV = rgb2hsv(foreground);
     pts = imbinarize(imfill(HSV(:,:,3).*is_obj,'holes')-HSV(:,:,3).*is_obj);
end


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
            obj = zeros(size(pts));
            obj(elements.PixelIdxList{num}) = 1;
            is_marker{ind} = obj;
            ind = ind +1;
        end
    end

end

  