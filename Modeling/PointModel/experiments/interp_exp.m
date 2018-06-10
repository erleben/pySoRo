
[x,y] = meshgrid(0:0.4:2,0:0.4:2);
u = cos(x).*y;
v = sin(x).*y;

A = [reshape(x,numel(x),1),reshape(y,numel(y),1)];
B = A + [reshape(u,numel(u),1),reshape(v,numel(v),1)]*0.2;

p = A(10,:);
%A(10,:)=[];
%B(10,:)=[];


figure;
hold on;
scatter([A(:,1); p(1); ],[A(:,2); p(2);],14,'k','f');

U = B-A;
gauss = @(x,p, sigma) exp(-(0.5*(sum((x-p).^2,2))/sigma^2));

G=gauss(A, p, 0.3);

w = (G/sum(G));
u = (U'*w)';
p_n = p+u;


wp_n = p+u;
quiver(A(:,1),A(:,2),U(:,1),U(:,2),0,'k')
quiver(p(1),p(2),u(1),u(2),0,'r')
axis([0 1.8 0.7 2.5])
legend('Observed point', 'Observed displacement', 'Approximated displacement');
xlabel('x');
ylabel('y');