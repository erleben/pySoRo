%pc2 = pcread('complete.ply');
pc1 = pcread('half.ply');

pcshow(pc1);
set(gcf,'color','w');
set(gca, 'ZDir','reverse');
 grid off
 axis off
OptionZ.FrameRate=20;OptionZ.Duration=5.5;OptionZ.Periodic=true;
% 
CaptureFigVid([-20,80;-110,10; -190,80;0,-40], 'complete_nice',OptionZ)