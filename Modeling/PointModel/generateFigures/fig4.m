A = csvread('data_files/alphamap.csv');
P=csvread('data_files/ordered_twoP.csv');

A(:,1) = [];
P(1:13*51,:) = [];
A(1:13*51,:)=[];

A = A - min(A);

% K: The number of partitions
K = 5;
[a, c] = kmeans(A,K);

% Scatter the partitioned configurations
figure;
h = scatter(c(:,1),c(:,2),'k','f');

% Scatter the centroids of the regions
hold on;
col = distinguishable_colors(K+1);
[s,i]=sort(sum(col,2));
col = col(flipud(i),:);
gscatter(A(:,1),A(:,2),a,col(1:end-1,:),[],50);

xlabel('\alpha_1','FontSize',15);
ylabel('\alpha_2','FontSize',15);

h =legend('Centroid');
axis([-10,310-78,-10,310]);
h = scatter(c(:,1),c(:,2),'k','f');
h = legend;
h.String(2)=[];

% Scatter plot one of the visual markers
figure;
for n = 9
    for i  = 1:K
        hold on;
        scatter3(P(a==i,n*3-2),P(a==i,n*3-1),P(a==i,n*3),5,col(i,:),'filled')
    end
end

view([10,20])
xlabel('x','FontSize',15);
ylabel('y','FontSize',15);
zlabel('z','FontSize',15);