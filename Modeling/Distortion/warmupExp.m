% NB: You have to gather data using staticDistortionMeasure.py before 
% running this script. It measures the time it takes for the sensors to 
% warm up and finds the amount of random noise in the depth data

clear;

num = 400;
times = csvread('../../../data/distortion_SR300/times.csv');
t = [0; cumsum(diff(times))];

% Color

C_Stats = zeros(num,3);
for i = 1:num
   img = int16(imread(strcat('../../../data/distortion_SR300/color',int2str(i-1),'.tif')));
   for ch = 1:3
       channel = img(:,:,ch);
       C_Stats(i, ch) = mean(channel(:));
   end
   
end

figure;
plot(t, C_Stats(:,1),'r', t,C_Stats(:,2),'g', t,  C_Stats(:,3), 'b');
legend('Mean red', 'Mean green', 'Mean blue');
xlabel('time (s)');
ylabel('mean pixel value');



% % Depth
% I_D = int16(imread(strcat('../../../data/distortion_D415/depth_',int2str(num-1),'.tif')));
% is_obj=bwareafilt(imbinarize(I_D),1);
% I_D = I_D(is_obj); 
% D_Stats = zeros(num-1,2);
% for i = 0:num-2
%    img = int16(imread(strcat('../../../data/distortion_D415/depth_',int2str(i),'.tif')));
%    img = img(is_obj);
%    
%    D_Stats(i+1,1) = mean(abs(double(I_D(:)-img(:))));
%    D_Stats(i+1,2) = sqrt(var(double(I_D(:)-img(:))));
% end
% 
% figure;
% plot(t, D_Stats(:,1),'k', t, D_Stats(:,2), 'r');
% legend('Mean difference','Standard deviation');
% xlabel('time (s)');
% ylabel('pixels');
% title('Depth');
% 
% scale = 0.00012498664727900177;
% figure;
% D_Stats = D_Stats*scale;
% plot(t, D_Stats(:,1),'k', t, D_Stats(:,2), 'r');
% legend('Mean difference','Standard deviation');
% xlabel('time (s)');
% ylabel('distance (m)');
% title('Depth');
% 
% %Random noise distribution:
% figure;
% hist(D_Stats(:,1),30);
% xlabel('Mean absolute distance');
% ylabel('Frequency');