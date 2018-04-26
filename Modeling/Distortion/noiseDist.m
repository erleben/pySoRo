clear;
D = zeros(180,250,400);
for i = 0:399
   d = int16(imread(strcat('../../../data/distortion_D415/depth_',int2str(i),'.tif')));
   D(:,:,i+1) = d(200:380-1,550:800-1);
end

avg = mean(D,3);

N = zeros(180,250,400);
for i = 0:399
   d = int16(imread(strcat('../../../data/distortion_D415/depth_',int2str(i),'.tif')));
   N(:,:,i+1) = double(d(200:380-1,550:800-1))-avg;
end

V=var(N,0,3);
VV = V;
VV(V>10)=0;
imagesc(VV);
disp('std:')

%\vec{s} = \tilde(s) + N(0,var)
%use in nosie analysis
sqrt(sum(N(abs(N)<10).^2)/numel(N(abs(N)<10)))