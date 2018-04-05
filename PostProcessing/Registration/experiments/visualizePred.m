figure;
P = csvread('../../Calibration/datapoints_pca.csv');


for i = 10:10:340
    
    JK=load('JK');
    JK=JK.JK;
    
    p = JK'*[i; 0.5*i^2];
    
    p = reshape(p,length(p)/3,3)+reshape(X0,length(p)/3,3);
    
    scatter3(p(:,1),p(:,2),p(:,3),'r');
    hold on;
end

for i = 1:7
    scatter3(P(:,3*i-2),P(:,3*i-1),P(:,3*i), 'b');
    hold on;
end