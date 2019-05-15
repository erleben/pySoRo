function [R,T,S,mse] = getWorldCalibration(Real_Centroids, Centroids1, Centroids2)
%GETWORLDCALIBRATION Summary of this function goes here
%   Detailed explanation goes here

center1 = [];
center2 = [];
for i = 1:length(Centroids1)
    for j = 1:length(Centroids1)
        if j ~= i
            a1 = Centroids1(j,:) - Centroids1(i,:);
            a2 = Centroids2(j,:) - Centroids2(i,:);
            for k = 1:length(Centroids1)
                if k ~= j && k ~= i
                   b1 = Centroids1(k,:) - Centroids1(i,:);
                   ang1 = rad2deg(atan2(norm(cross(a1,b1)), dot(a1,b1)));
                   if abs(ang1-90) < 4.0
                       center2 = i;
                       dists{1}(i) = 0.0;
                       dists{1}(j) = norm(a1);
                   end
                   b2 = Centroids2(k,:) - Centroids2(i,:);
                   ang2 = rad2deg(atan2(norm(cross(a2,b2)), dot(a2,b2)));
                   if abs(ang2-90) < 4.0
                       center2 = i;
                       dists{2}(i) = 0.0;
                       dists{2}(j) = norm(a2);
                   end
                end
            end
            
        end
    end
end

real_dists = [];
for i = 1:length(Real_Centroids.coordinates)
    real_dists = [real_dists; norm(Real_Centroids.coordinates(i,:))];
end

[out1, idx1] = sort(dists{1}, 'ascend');
[out2, idx2] = sort(dists{2}, 'ascend');
[out3, idx3] = sort(real_dists, 'ascend');
out3
idx3
R{1} =[];
R{2} =[];
S{1} = [];
S{2} = [];
for i = 2:4
    e1 = Centroids1(idx1(idx3(i)),:) - Centroids1(idx1(idx3(1)),:);
    e1n = e1/norm(e1);
    R{1} = [R{1};e1n];
    S{1} = [S{1}, real_dists(idx3(i))/norm(e1)];
    e2 = Centroids2(idx2(idx3(i)),:) - Centroids2(idx2(idx3(1)),:);
    e2n = e2/norm(e2);
    R{2} = [R{2};e2n];
    S{2} = [S{2}, real_dists(idx3(i))/norm(e2)];
    
    %     e2 = e2/norm(e2);
    %     e3 = e3/norm(e3); %e1, e2, e3 must be normalized firstly
end

R{1} = R{1};
R{2} = R{2};
% Translation for coordinate system.
T{1} = Real_Centroids.coordinates(1,:)-Centroids1(idx1(1),:);
T{2} = Real_Centroids.coordinates(1,:)-Centroids2(idx2(1),:);

mse = 0;
for i = 1:4
    mse = mse + norm(Centroids2(idx2(i),:)-Centroids1(idx1(i),:));
end
mse = mse/4
end

