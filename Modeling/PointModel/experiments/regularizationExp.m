order = 7;
lam = 0.001;
for i = 1:1
X = datasample(1:0.01:10,20,'Replace',false);
XR = X;
minX = min(X);
X = X-minX;
maxX = max(X);
X = X/maxX;

XX = makeAlpha(X,order,true);
Z = (XR -7+ normrnd(0,0.5,1,length(X))).^2 + 5;


scatter(XR,Z);

w_noreg = (XX*XX')\(Z*XX')';

IL = eye(size(XX*XX'))*lam;
IL(1)=0;
ww_wreg = (XX*XX'+IL)\(Z*XX')';
w_real = (XX*XX')\(((X-7).^2)*XX')';

xxx = linspace(min(X),max(X),100);
xx = makeAlpha(xxx,order,true);
yy = xx'*w_noreg;
hold on;
xxx = (xxx*maxX)+minX;
plot(xxx,yy,'r'); 

plot(xxx,xx'*ww_wreg,'b');

%plot(xxx,xx'*w_real);
end
legend('Data','Without reg', 'With reg');
