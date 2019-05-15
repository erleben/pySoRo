function I = pcloud2rgb(pcloud)
%PCLOUD2RGB Summary of this function goes here
%   Detailed explanation goes here
locations = pcloud.Location;
x = locations(:,1);
y = locations(:,2);
xspan = abs(max(x)-min(x));
yspan = abs(max(y)-min(y));

xdim = 800;
ydim = 640;
bucket_sizex = xspan/xdim;
bucket_sizey = yspan/ydim;
I = zeros(xdim, ydim, 3);
for i = 1:xdim
    new_x{i} = [];
end

for i = 1:ydim
    new_y{i} = [];
end

for i = 1:length(x)
    ind = int32(x(i)/bucket_sizex);
    new_x{ind} = [new_x{ind}; i];
    ind = int32(y(i)/bucket_sizey);
    new_y{ind} = [new_y{ind}; i];
end



% yrange = length(y)/yspan;
% ypixels = (y+min(y)).*xrange



end

