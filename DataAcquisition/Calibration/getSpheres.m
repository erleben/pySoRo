function spheremodels = getSpheres(balls, pc, tex_name, showClouds)

[height, width] = size(balls{1});

tex = imread(tex_name);
ispoint = logical((tex(:,1)~=0).*(tex(:,2)~=0));

tex_imco = round(tex.*[width,height]);
[numBalls, ~] = size(balls);


for num = 1:numBalls
    isBall = balls(num,1);
    isBall = isBall{1};

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
    
    isBallList = isBallList(ispoint,:);
    Loc = pc.Location;
    Loc(~isBallList,:)=[];
    Col = pc.Color;
    Col(~isBallList,:)=[];
    newpc=pointCloud(Loc,'Color',Col);
    [model, ~] = pcfitsphere(newpc, 0.001);
    spheremodels{num} = model;
end 

if showClouds
    pcshow(pc);
    hold on; 
    for num = 1:numBalls
        plot(spheremodels{num});
        hold on;
    end
    
end

end