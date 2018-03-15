
makeNew = true;
n = 40;
if makeNew


    pc = load('sponge.mat');
    pc = pc.PP;
    
    Loc=pc.Location-[sum(pc.XLimits)/2,sum(pc.YLimits)/2,sum(pc.ZLimits)/2];
    pc = pointCloud([Loc; -Loc]);
    pc = pcdenoise(pcdownsample(pc,'GridAverage',0.006),'Threshold', 1);
    
    xs = linspace(pc.XLimits(1),pc.XLimits(2),n)*1.3;
    ys = linspace(pc.YLimits(1),pc.YLimits(2),n)*1.3;
    zs = linspace(pc.ZLimits(1),pc.ZLimits(2),n)*1.3;
    
    distM = zeros(length(xs),length(ys),length(zs));
    
    for i = 1:length(xs)
        for j = 1:length(ys)
            for k = 1:length(xs)
                distM(i,j,k) = distpc([xs(i),ys(j),zs(k)],pc);
                %distM(i,j,k) = dbox([xs(i),ys(j),zs(k)],max(xs)*1.5,max(ys)*1.5,max(zs)*1.5);

            end
        end
    end
    
    figure;
    for i = 1:n
        imagesc(distM(:,:,i));
    end
    
    save('distM','distM')

else 
    distM = load('distM');
    distM = distM.distM;
end

distMM = distM;
for z = 1:n
    distMM(:,:,z)=imopen(imclose(distM(:,:,z)<0.001,strel('disk',10)),strel('disk',4));
end

distMS = -abs(distM.*distMM) + abs(distM).*(~logical(distMM));
 
figure;
for i = 1:n
    imagesc(distMM(:,:,i));
    drawnow;
    %waitforbuttonpress
end
 
figure;
for i = 1:n
   imagesc(distMS(:,:,i));
   colorbar();
   drawnow;
end

save('distMS','distMS');
save('distMSgrid.mat','xs','ys','zs');