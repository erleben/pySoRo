function balls = getBallProps(back_name, fore_name)

right_fore = imread(fore_name);
right_back = imread(back_name);

BW=imbinarize(right_fore-right_back);
isBall = BW(:,:,1); 
isBall = imopen(isBall,strel('disk',4));
isBall = imerode(isBall, strel('disk', 3));
elements = bwconncomp(isBall);
balls = {elements.NumObjects, 1};

for num = 1:elements.NumObjects
    if num > 1 
     ball = bwareafilt(isBall, num) -bwareafilt(isBall,num-1);
    else
     ball = bwareafilt(isBall, num);
    end
    balls{num, 1} = ball;
end

end



 