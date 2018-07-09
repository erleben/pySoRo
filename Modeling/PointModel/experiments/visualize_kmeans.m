A = csvread('../data/alphamap.csv');
P=csvread('../data/ordered_twoP.csv');
A(:,1) = [];

P(1:13*51,:) = [];
A(1:13*51,:)=[];
A = A - min(A);

K = 5;
[a, c] = kmeans(A,K);
figure;
h = scatter(c(:,1),c(:,2),'k','f');
hold on;
col = distinguishable_colors(K+1);
[s,i]=sort(sum(col,2));
col = col(flipud(i),:);
gscatter(A(:,1),A(:,2),a,col(1:end-1,:),[],50);

%imagesc(reshape(a,51,51));

xlabel('\alpha_1','FontSize',15);
ylabel('\alpha_2','FontSize',15);

h =legend('Centroid');

axis([-10,310-78,-10,310]);
h = scatter(c(:,1),c(:,2),'k','f');
h = legend;
h.String(2)=[];

figure;
for n = 9
for i  = 1:K
    hold on;
    scatter3(P(a==i,n*3-2),P(a==i,n*3-1),P(a==i,n*3),5,col(i,:),'filled')
end
end

xlabel('x','FontSize',15);
ylabel('y','FontSize',15);
zlabel('z','FontSize',15);