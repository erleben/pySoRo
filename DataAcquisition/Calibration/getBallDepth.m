function depth = getBallDepth(isBall, pc, tex_name)

width = 640;
height = 480;

tex = imread(tex_name);

tex_imco = round(tex.*[width,height]);
isBallList = zeros(width*height,1);
for i = 1:length(tex_imco)
    x = tex_imco(i,1);
    y = tex_imco(i,2);
    
    if (x<width) && (x>0) && (y<height) && (y>0)
        if isBall(y,x) == 1
            isBallList(i) = 1;
        end
    
    end
end
ispoint = logical((tex(:,1)~=0).*(tex(:,2)~=0));
isBallList = isBallList(ispoint,:);
Loc = pc.Location;
Loc(~isBallList,:)=[];
Col = pc.Color;
Col(~isBallList,:)=[];
newpc=pointCloud(Loc,'Color',Col);
pcshow(newpc,'MarkerSize', 50)

imshow(reshape(isBallList,640,480))
end