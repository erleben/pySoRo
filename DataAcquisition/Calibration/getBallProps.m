function balls = getBallProps(fore_name, back_name)

right_fore = imread(fore_name);
right_back = imread(back_name);

BW=imbinarize(right_back-right_fore);
isBall = BW(:,:,1);
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



 