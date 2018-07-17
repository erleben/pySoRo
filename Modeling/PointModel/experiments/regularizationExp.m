% Fit a curve to noisy data with and without regularization

order = 7;
lam = 0.001;

A = datasample(1:0.01:10,20,'Replace',false);
A_orig = A;
minA = min(A);
A = A-minA;
maxA = max(A);
A = A/maxA;

A_JK = makeAlpha(A,order,true);
X = (A_orig -7+ normrnd(0,0.5,1,length(A))).^2 + 5;


scatter(A_orig,X);

w_noreg = (A_JK*A_JK')\(X*A_JK')';

IL = eye(size(A_JK*A_JK'))*lam;
IL(1)=0;
w_reg = (A_JK*A_JK'+IL)\(X*A_JK')';

a_sample = linspace(min(A),max(A),100);
a_JK = makeAlpha(a_sample,order,true);
yy = a_JK'*w_noreg;
hold on;
a_sample = (a_sample*maxA)+minA;
plot(a_sample,yy,'r'); 

plot(a_sample,a_JK'*w_reg,'b');

legend('Data','Without reg', 'With reg');
