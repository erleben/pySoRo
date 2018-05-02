% NB: You have to gather data using staticDistortionMeasure.py before 
% running this script. 
clear;

vthr = 0.02^2;
cam = 'SR300';
do_crop = false;
num_obs = 400;

if strcmp(cam, 'D415')
    scale = 0.0001;
else
    scale = 0.00012498664727900177;
end

c = imread(strcat('../../../data/distortion_', cam, '/color',int2str(300),'.tif'));
ROI = imerode(imbinarize(c(:,:,1)), strel('disk',50));

D = zeros(size(c,1), size(c,2), num_obs);
for i = 0:num_obs-1
   D(:,:,i+1) = int16(imread(strcat('../../../data/distortion_', cam,'/depth_',int2str(i),'.tif')));
end

avg = mean(D,3);

N = zeros(size(c,1), size(c,2), num_obs);
for i = 0:num_obs-1
   d = double(imread(strcat('../../../data/distortion_', cam, '/depth_',int2str(i),'.tif'))) - avg;
   d = d*scale;
   d(logical(ROI<1)) = nan;
   N(:,:,i+1) = d;
end 



V=var(N,0,3);
VV = V;
VV(V>vthr)=0;
figure;
imagesc(VV);
hcb = colorbar();
set(get(hcb,'Title'),'String','Variance')
xlabel('x');
ylabel('y');

ROI(V>vthr) = 0;
for i = 1:num_obs
    d = N(:,:,i);
    d(~ROI) = nan;
    N(:,:,i) = d;
end
in = isnan(N);
disp('var:')
var(N(~in))
disp('std:')
sqrt(var(N(~in)))

figure
if strcmp(cam, 'D415')
    histfit(N(~in),120)
    legend('Observed distribution','Fitted distribution')
    axis([-0.003 0.003 0 3500000])
    xlabel('Random noise (m)')
    ylabel('Frequency');
    pd=fitdist(N(~in),'Normal')
else
    histogram(N(~in),120)
    xlabel('Deviance')
    ylabel('Frequency');
end

disp('mean absolute error')
mean(abs(N(~in)));

disp('mean error')
mean(N(~in))