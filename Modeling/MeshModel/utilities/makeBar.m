min_len = 0.008;
w = 0.09;
l = 0.065;
h = 0.04;
fd = inline(sprintf('dbox(p,%d,%d,%d)', w,h,l),'p');

[p, T] = distmeshnd(fd,@huniform, min_len,[-w,-l,-h;w,l,h]*1.2,[]);

raw_pc = load('sponge.mat');
pc = raw_pc.PP;

pc = pcdenoise(pc,'NumNeighbors',2,'Threshold',0.7);
pc = pcdenoise(pcdownsample(pc,'Gridaverage',0.007))

TR=triangulation(T,p);

ff=freeBoundary(TR);
fn=unique(reshape(ff, length(ff)*3, 1));
free = zeros(length(p),1);
free(fn)=1;


bot=p(:,3)-min(p(:,3))>0.001;
free(bot)=0;

pc_bar = pointCloud(p(logical(free),:));
pcshow(pc_bar, 'MarkerSize', 100);
hold on;

tform = pcregrigid(pc, pc_bar, 'InlierRatio', 0.2);

new_pc = pctransform(raw_pc.PP, tform);

pcshow(new_pc,'MarkerSize', 50);
hold on;
%tetramesh(T,p,'FaceAlpha',0.2);

save('sponge_pc.mat','new_pc')
save('sponge_bar.mat', 'T', 'p');