function [ball, radius, centroid] = getBallProps(fore_name, back_name, num)

right_fore = imread(fore_name);
right_back = imread(back_name);

BW=imbinarize(right_back-right_fore);
isBall = BW(:,:,1);
if num > 1
    ball = bwareafilt(isBall, num) -bwareafilt(isBall,num-1);
else
    ball = bwareafilt(isBall, num);
end



area = sum(ball(:));
radius = sqrt(area/pi);
props = regionprops(ball, 'Centroid');
centroid = props.Centroid;

end
