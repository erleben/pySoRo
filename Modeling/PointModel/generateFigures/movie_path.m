clear;
[~,path]=path_finding(1000, 30, 5000, true);
distance = sqrt(sum(diff(path).^2,2));
num_legs = size(distance);

ind = 1;
fd=gcf;
fd.delete;
set(gcf,'color','w');

for i = 1:num_legs
    for j = 1:3:round(distance(i))
        l = round(distance(i));
        start = path(i,:);
        stop = path(i+1,:);
        dif = (stop-start)/l;
        pos = start + dif*j;
      hold on
      h = scatter(pos(1),pos(2),300,[ 0.9100 0.4100 0.1700],'o','f');
      legend({'Path Chosen','Sampled Configurations', 'Collision Configurations', 'Start Configuration', 'Goal Configuration','Current Configuration'},'Location','southeast');
      hold off
      F(ind) = getframe(gcf) ;
      delete(h)
      drawnow
      ind = ind +1;
    end
end
  % create the video writer with 1 fps
  writerObj = VideoWriter('myVideo.mp4');
  writerObj.FrameRate = 26;00,[ 0.9100 0.4100 0.1700],'o','f');
      legend({'Path Chosen','Sampled Configurations', 'Collision Configurations', 'Start Configuration', 'Goal Configuration','Current Configuration'},'Location','southeast');
      hold off
      F(ind) = getframe(gcf) ;
      delete(h)
      drawnow
      ind = ind +1;
    end
end
  % create the video writer with 1 fps
  writerObj = VideoWriter('myVideo.mp4');
  writerObj.FrameRate = 26;
  % set the seconds per image
% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F)
    % convert the image to a frame
    frame = F(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
  % set the seconds per image
% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F)
    % convert the image to a frame
    frame = F(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);